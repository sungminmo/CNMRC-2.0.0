/*
Ê* Copyright 2012 Google Inc. All Rights Reserved.
Ê*
Ê* Licensed under the Apache License, Version 2.0 (the "License");
Ê* you may not use this file except in compliance with the License.
Ê* You may obtain a copy of the License at
Ê*
Ê* Ê Ê Êhttp://www.apache.org/licenses/LICENSE-2.0
Ê*
Ê* Unless required by applicable law or agreed to in writing, software
Ê* distributed under the License is distributed on an "AS IS" BASIS,
Ê* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
Ê* See the License for the specific language governing permissions and
Ê* limitations under the License.
Ê*/

#include "PoloCertificatesStorage.h"
#include <uuid/uuid.h>
#include <openssl/md5.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>
#include <openssl/err.h>


#pragma mark Disk storage implementation

// NOTE: We store certificate in the format suggested by OpenSSL. We store each
// certificate in its own PEM file, where the file name is the subject's hash
// as returned by X509_subject_name_hash(). If two certificates have the same
// hash, we differentiate them by their extension. The extension is an index
// that starts at zero and goes up.

// The internal data structure of disk storage. This is what the |info| field
// points to.
typedef struct PoloCertificatesStorageDiskInternals {
  const char *directory;
} PoloCertificatesStorageDiskInternals;

// A shorthand for getting the internals
static inline PoloCertificatesStorageDiskInternals *
PoloCertificatesStorageDiskGetInternals(PoloCertificatesStorageRef storage) {
  return storage->info;
}

// A shorthand for getting the directory of the storage
const char *
PoloCertificatesStorageGetDirNoCheck(PoloCertificatesStorageRef storage) {
  return PoloCertificatesStorageDiskGetInternals(storage)->directory;
}

// Computes an MD5 for a PEM containing the given X509 certificate.
// In order to compute the digest the function writes the PEM to a temp file.
// You're responsible for providing |tmpFile|, which must already be opened for
// reading and writing. This function does not close it when it exists.
//
// |md5Digest| must be of size MD5_DIGEST_LENGTH + 1. The returned digest is
// NULL terminated.
#if 0
static int PoloComputeMD5ForX509Certificate(X509 *certificate,
                                            unsigned char *md5Digest,
                                            FILE *tmpFile) {
  BIO *bio = BIO_new_fp(tmpFile, BIO_NOCLOSE);
  int returnCode = kPoloCertificatesStorageErrNone;

  if (!bio) {
    returnCode = kPoloCertificatesStorageDiskErrCanNotCreateFile;
    goto cleanup;
  }

  if (!PEM_write_bio_X509(bio, certificate)) {
    returnCode = kPoloCertificatesStorageDiskErrCanNotWritePEMToFile;
    goto cleanup;
  }

  // Get the length of the PEM of the certificate written to the file
  size_t pemLength = ftell(tmpFile);
  // Read the PEM to memory
  void *pemData = malloc(pemLength);
  rewind(tmpFile);
  pemLength = fread(pemData, 1, pemLength, tmpFile);

  // Compute an MD5 digest from it
  MD5(pemData, pemLength, md5Digest);
  md5Digest[MD5_DIGEST_LENGTH] = '\0';
  free(pemData);

cleanup:
  if (bio)
    BIO_free(bio);

  return returnCode;
}
#endif

const char *PoloBase64StringFromString(const char *str) {
  BIO *bmem, *b64;
  BUF_MEM *bptr;
  size_t length = strlen(str) * sizeof(char);

  b64 = BIO_new(BIO_f_base64());
  bmem = BIO_new(BIO_s_mem());
  b64 = BIO_push(b64, bmem);
  BIO_write(b64, str, length);
  BIO_flush(b64);
  BIO_get_mem_ptr(b64, &bptr);

  char *buff = (char *)malloc(bptr->length);
  memcpy(buff, bptr->data, bptr->length-1);
  buff[bptr->length-1] = 0;

  BIO_free_all(b64);

  return buff;
}

#define POLO_PEM_PATH_EXT_LENGTH 10

// Creates and returns a string with the prefix of the PEM file's path.
// The returned string is NOT NULL tarminated. You should pass the returned
// string through PoloCertificatesStorageDiskUpdatePEMPath() which will make
// it a true path.
// You're responsible for freeing the returned string.
// Parameters:
//  |storage|   - The disk certificates storage for which stored the
//                certificate.
//  |name|      - The name of the certificate file (without extension).
//  |outPrefix| - On return, holds the prefix of the path. You should pass the
//                returned value to PoloCertificatesStorageDiskUpdatePEMPath().
char *PoloCertificatesStorageDiskCreatePEMPathTemplate(
  PoloCertificatesStorageRef storage,
  const char *name,
  size_t *outPrefix) {

  const char *directoryPath = PoloCertificatesStorageGetDirNoCheck(storage);
  size_t directoryPathLen = strlen(directoryPath);
  size_t nameLen = strlen(name);
  // The added 13 chars are:
  // - '/'
  // - '.'
  // - 10 Characters for the number of the file (10 chars can hold 32 bit int)
  // - Terminating NULL
  char *newFilePath = calloc(directoryPathLen + nameLen + 3 +
                             POLO_PEM_PATH_EXT_LENGTH,
                             sizeof(char));
  
  memcpy(newFilePath, directoryPath, directoryPathLen * sizeof(char));
  newFilePath[directoryPathLen] = '/';
  memcpy(newFilePath + directoryPathLen + 1,
         name,
         nameLen * sizeof(char));
  newFilePath[directoryPathLen + nameLen + 1] = '.';
  if (outPrefix)
    *outPrefix = directoryPathLen + nameLen + 2;
  return newFilePath;
}

// Updates a given path to point to the specified certificate path.
// Parameters:
//       |storage| - The disk storage that stored the certificate.
//          |path| - The path to update. The path must have been constructed by
//                   PoloCertificatesStorageDiskCreatePEMPathTemplate().
//  |prefixLength| - The length returned in the |outPrefix| parameter of
//                   PoloCertificatesStorageDiskCreatePEMPathTemplate().
//         |index| - The index of the certificate. Certificates with identical
//                   names must have different indexes, starting at 0.
void
PoloCertificatesStorageDiskUpdatePEMPath(PoloCertificatesStorageRef storage,
                                         char *path,
                                         size_t prefixLength,
                                         uint32_t index) {
  snprintf(path + prefixLength, POLO_PEM_PATH_EXT_LENGTH, "%u", index);
}

// This function allocates and returns a full path to the PEM file named |name|
// in the storage directory of the given disk storage. You're responsible for
// freeing the result.
char *
PoloCertificatesStorageDiskCreatePEMPathWithName(PoloCertificatesStorageRef storage,
                                                 const char *name) {
  char *newFilePath;
  size_t prefixLength;
  newFilePath = PoloCertificatesStorageDiskCreatePEMPathTemplate(storage,
                                                                 name,
                                                                 &prefixLength);
  uint32_t fileIndex = 0;
  PoloCertificatesStorageDiskUpdatePEMPath(storage,
                                           newFilePath,
                                           prefixLength,
                                           fileIndex);
  while (!access(newFilePath, F_OK)) {
    ++fileIndex;
    PoloCertificatesStorageDiskUpdatePEMPath(storage,
                                             newFilePath,
                                             prefixLength,
                                             fileIndex);
  };
  return newFilePath;
}

static char *copyNameForCertificate(X509 *certificate) {
  unsigned long hash = X509_subject_name_hash(certificate);
  char *name;
  size_t len = snprintf(NULL, 0, "%08lx", hash);
  name = malloc(sizeof(char) * (len + 1));
  snprintf(name, sizeof(char) * (len + 1), "%08lx", hash);
  return name;
}

// Check that the given storage is a disk storage
#define CHECK_DISK_STORAGE_CLASS(storage) \
do {\
  if (storage->storageClass != PoloCertificatesStorageDiskClass)\
    return kPoloCertificatesStorageErrInvalidClass;\
} while (0);

int PoloCertificatesStorageDiskAddCertificate(PoloCertificatesStorageRef storage,
                                              X509 *certificate) {
  CHECK_DISK_STORAGE_CLASS(storage);
  const char *name = copyNameForCertificate(certificate);
  char *filePath = PoloCertificatesStorageDiskCreatePEMPathWithName(storage,
                                                                    name);
  FILE *file = fopen(filePath, "w+");
  int returnCode = kPoloCertificatesStorageErrNone;

  free((void *)name);

  if (!file)
    returnCode =  kPoloCertificatesStorageDiskErrCanNotCreateFile;

  if (returnCode == kPoloCertificatesStorageErrNone &&
      PEM_write_X509(file, certificate) != 1) {
    unlink(filePath);
    returnCode = kPoloCertificatesStorageDiskErrCanNotWritePEMToFile;
  }

  free(filePath);
  fclose(file);
  return returnCode;
}

int
PoloCertificatesStorageDiskRemoveCertificate(PoloCertificatesStorageRef storage,
                                             X509 *certificate) {
  CHECK_DISK_STORAGE_CLASS(storage);
  int returnCode = kPoloCertificatesStorageErrNone;
  const char *name = copyNameForCertificate(certificate);
  char *certificatePath;
  certificatePath = PoloCertificatesStorageDiskCreatePEMPathWithName(storage,
                                                                      name);
  free((void *)name);
  if (unlink(certificatePath)) {
    if (errno == ENOENT)
      returnCode = kPoloCertificatesStorageErrUnknownCertificate;
    else
      returnCode = kPoloCertificatesStorageDiskErrCanNotUnlinkFile;
  }
  free(certificatePath);
  return returnCode;
}

int PoloCertificatesStorageDiskSetTrustStore(PoloCertificatesStorageRef storage,
                                             SSL_CTX *sslContext) {
  CHECK_DISK_STORAGE_CLASS(storage);
  const char *certsDir = PoloCertificatesStorageGetDirNoCheck(storage);
  int returnCode = kPoloCertificatesStorageErrNone;

  if (!SSL_CTX_load_verify_locations(sslContext, NULL, certsDir)) {
    printf("%s", ERR_error_string(ERR_get_error(), NULL));
    returnCode = kPoloCertificatesStorageErrInternal;
  }

  return returnCode;
}

// Compares two OpenSSL BIGNUM instances. Returns 1 if equal, 0 otherwise.
int PoloBIGNUMEqual(BIGNUM *a, BIGNUM *b) {
  size_t sizeA = BN_num_bytes(a);
  size_t sizeB = BN_num_bytes(b);
  
  if (sizeA != sizeB)
    return 0;
  
  void *buffA = malloc(sizeA);
  void *buffB = malloc(sizeB);
  BN_bn2bin(a, buffA);
  BN_bn2bin(b, buffB);
  int result = memcmp(buffA, buffB, sizeA);
  free(buffA);
  free(buffB);
  return !result;
}

// Compare certificates. Returns kPoloCertificatesStorageErrNone if they're
// equal. Returns 1 if equal, 0 otherwise.
int PoloCertificatesStorageEqualCertificates(X509 *cert1, X509 *cert2) {
  // Currently we compare certificates by comparing they're RSA key.
  // This is correct only in the context of Polo.
  RSA *rsa1 = EVP_PKEY_get1_RSA(X509_get_pubkey(cert2));
  RSA *rsa2 = EVP_PKEY_get1_RSA(X509_get_pubkey(cert2));
  return PoloBIGNUMEqual(rsa1->n, rsa2->n) && PoloBIGNUMEqual(rsa1->e, rsa2->e);
}

int PoloCertificatesStorageDiskVerifyCert(PoloCertificatesStorageRef storage,
                                          X509 *certificate) {
  int returnCode = kPoloCertificatesStorageErrUnknownCertificate;
  char *name = copyNameForCertificate(certificate);
  size_t prefixLength;
  char *path = PoloCertificatesStorageDiskCreatePEMPathTemplate(storage,
                                                                name,
                                                                &prefixLength);
  uint32_t fileIndex = 0;
  free(name);
  
  do {
    PoloCertificatesStorageDiskUpdatePEMPath(storage,
                                             path,
                                             prefixLength,
                                             fileIndex);
    puts(path);
    FILE *filedesc = fopen(path, "r");
    if (filedesc) {
      X509 *storedCert = X509_new();
      if (PEM_read_X509(filedesc, &storedCert, NULL, NULL)) {
        if (PoloCertificatesStorageEqualCertificates(storedCert, certificate))
          returnCode = kPoloCertificatesStorageErrNone;
      }
      X509_free(storedCert);
      fclose(filedesc);
    } else {
      // Exit the loop if the file can't be opened (i.e doesn't exist)
      break;
    }
    
    ++fileIndex;
  } while (returnCode != kPoloCertificatesStorageErrNone);
  
  free((void *)path);
  return returnCode;
}

int PoloCertificatesStorageDiskInit(PoloCertificatesStorageRef storage,
                                    void *infoPtr) {
  PoloCertificatesStorageDiskInternals *info = infoPtr;

  CHECK_DISK_STORAGE_CLASS(storage);
  if (!info || !info->directory)
    return kPoloCertificatesStorageErrInvalidArgument;

  if (access(info->directory, F_OK) != 0) {
    return kPoloCertificatesStorageDiskErrDirectoryUnavailable;
  }

  size_t internalsSize = sizeof(PoloCertificatesStorageDiskInternals);
  PoloCertificatesStorageDiskInternals *internals = calloc(1, internalsSize);
  size_t pathLen = strlen(info->directory);
  internals->directory = malloc(pathLen + 1);
  memcpy((void *)internals->directory, info->directory, pathLen + 1);
  storage->info = internals;
  return kPoloCertificatesStorageErrNone;
}

void PoloCertificatesStorageDiskDestroy(PoloCertificatesStorageRef storage) {
  free((void *)PoloCertificatesStorageGetDirNoCheck(storage));
  free(storage->info);
}

struct PoloCertificatesStorageClass PoloCertificatesStorageDiskClassStruct = {
  NULL, // error reason
  PoloCertificatesStorageDiskAddCertificate,
  PoloCertificatesStorageDiskRemoveCertificate,
  NULL, // We don't set the trust store
  PoloCertificatesStorageDiskVerifyCert,
  PoloCertificatesStorageDiskInit,
  PoloCertificatesStorageDiskDestroy
};
const PoloCertificatesStorageClassRef
PoloCertificatesStorageDiskClass = &PoloCertificatesStorageDiskClassStruct;

#pragma mark -
#pragma mark Disk storage public API
PoloCertificatesStorageRef
PoloCertificatesStorageCreateDiskStorage(PoloMemoryAllocatorRef allocator,
                                         const char *directory,
                                         int *outError) {
  PoloCertificatesStorageDiskInternals info = { directory };
  return PoloCertificatesStorageCreate(allocator,
                                       PoloCertificatesStorageDiskClass,
                                       &info,
                                       outError);
}

int
PoloCertificatesStorageDiskGetDirectory(PoloCertificatesStorageRef storage,
                                        const char **outDirectory) {
  if (storage->storageClass != PoloCertificatesStorageDiskClass)
    return kPoloCertificatesStorageErrInvalidClass;

  if (outDirectory)
    *outDirectory = PoloCertificatesStorageGetDirNoCheck(storage);

  return kPoloCertificatesStorageErrNone;
}

#pragma mark -
#pragma mark Certificates storage public API

void PoloCertificatesStorageDestory(PoloType storage) {
  ((PoloCertificatesStorageRef)storage)->storageClass->destroy(storage);
}

PoloType PoloCertificatesStorageClassCopy(PoloType storage) {
  return PoloRetain(storage);
}

struct PoloClass PoloClassCertificatesStorageClass = {
  NULL, // Class isa
  NULL, // Instance isa
  sizeof(struct polo_certificates_storage),
  NULL, // We have our custom init
  PoloCertificatesStorageDestory,
  PoloCertificatesStorageClassCopy  // No copy at this time
};

struct PoloClass *PoloClassGetCertificatesStorageClass(void) {
  return &PoloClassCertificatesStorageClass;
}

PoloCertificatesStorageRef
PoloCertificatesStorageCreate(PoloMemoryAllocatorRef allocator,
                              PoloCertificatesStorageClassRef cls,
                              void *info,
                              int *outError) {
  struct PoloClass *class = PoloClassGetCertificatesStorageClass();
  PoloCertificatesStorageRef storage = PoloAlloc(allocator,
                                                 0,
                                                 class);
  int errorCode;

  storage->storageClass = cls;
  storage->info = info;
  errorCode = cls->init(storage, info);

  if (errorCode != kPoloCertificatesStorageErrNone) {
    PoloRelease(storage);
    storage = NULL;
  }

  if (outError)
    *outError = errorCode;

  return storage;
}

const char *
PoloCertificatesStorageGetErrorReason(PoloCertificatesStorageRef storage,
                                      int errorCode) {
  if (storage->storageClass->getErrorReason)
    return storage->storageClass->getErrorReason(storage, errorCode);
  else
    return NULL;
}

int
PoloCertificatesStorageAddCertificate(PoloCertificatesStorageRef storage,
                                      X509 *certificate) {
  return storage->storageClass->addCertificate(storage, certificate);
}

int
PoloCertificatesStorageRemoveCertificate(PoloCertificatesStorageRef storage,
                                         X509 *certificate) {
  return storage->storageClass->removeCertificate(storage, certificate);
}

int
PoloCertificatesStorageSetTrustStore(PoloCertificatesStorageRef storage,
                                     SSL_CTX *sslContext) {
  if (storage->storageClass->setTrustStore)
    return storage->storageClass->setTrustStore(storage, sslContext);
  else
    return kPoloCertificatesStorageErrOperationNotSupported;
}

int
PoloCertificatesStorageCanSetTrustStore(PoloCertificatesStorageRef storage) {
  return storage->storageClass->setTrustStore != NULL;
}

int
PoloCertificatesStorageVerifyCertificate(PoloCertificatesStorageRef storage,
                                         X509 *certificate) {
  if (storage->storageClass->verifyCertificate)
    return storage->storageClass->verifyCertificate(storage, certificate);
  else
    return kPoloCertificatesStorageErrOperationNotSupported;
}

int
PoloCertificatesStorageCanVerifyCertificate(PoloCertificatesStorageRef storage) {
  return storage->storageClass->verifyCertificate != NULL;
}
