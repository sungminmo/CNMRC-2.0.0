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

#ifndef HEADER_POLO_CERTIFICATES_STORAGE_H
#define HEADER_POLO_CERTIFICATES_STORAGE_H

#include <openssl/x509v3.h>
#include <openssl/ssl.h>
#include <Polo/PoloBase.h>

#ifdef  __cplusplus
extern "C" {
#endif


typedef struct polo_certificates_storage *PoloCertificatesStorageRef;

struct PoloCertificatesStorageClass {
  // Given an error code this function is expected to return a human readable
  // reason for the error. It should return NULL if no reason is available.
  // |storage| is the object that returned the error.
  const char *(*getErrorReason)(PoloCertificatesStorageRef storage,
                                int errorCode);
  // Given a certificate this function is expected to add it to the storage.
  // The function must return 0 on success. Any other return value is treated
  // as an error code.
  int (*addCertificate)(PoloCertificatesStorageRef storage,
                        X509 *certificate);
  // This function is expected to remove the given certificate from the storage.
  // The return code follows the same rules as above.
  int (*removeCertificate)(PoloCertificatesStorageRef storage,
                           X509 *certificate);
  // This function should set all certificates of the storage as the trust store
  // of the given SSL context. Return code follows the same ruls as above.
  // May be NULL if not supported by storage class.
  int (*setTrustStore)(PoloCertificatesStorageRef storage, SSL_CTX *sslContext);
  // Verifies a given certificate. Returns kPoloCertificatesStorageErrNone if
  // the certificate is to be trusted.
  // May be NULL if not supported by storage class.
  int (*verifyCertificate)(PoloCertificatesStorageRef storage,
                           X509 *certificate);
  // This function is called when creating a new storage instance. You can do
  // whatever you want with it. It may be NULL if you have no init code.
  // |info| is passed unmodified from PoloCertificatesStorageCreate(). It's all
  // yours.
  // If an error had occurred during initialization you must free all memory you
  // allocated and return an error code. On a successful initialization you must
  // return |kPoloCertificatesStorageErrNone|.
  int (*init)(PoloCertificatesStorageRef storage, void *info);
  // This function is called when destroying a storagte instance. You should
  // perform any needed cleanups in it. Set to NULL if you have no cleanup code.
  // You must not free |storage| itself.
  void (*destroy)(PoloCertificatesStorageRef storage);
};
typedef struct PoloCertificatesStorageClass *PoloCertificatesStorageClassRef;

// A certificates storage is an abstract mechanism used to store certificates.
// It handles adding, deleting and loading certificates. It may store
// certificates in any medium needed. No definition for the lifetime of the
// storage is given, and may either be a permanent storage or not.
//
// Unless you're implementing a certificates storage, you should consider all
// fields private.
struct polo_certificates_storage {
  struct PoloBase base;
  PoloCertificatesStorageClassRef storageClass;
  // This variable is reserved for the storage's implementation. If you're
  // writing a certificates storage you can use this variable for whatever you'd
  // like.
  void *info;
};

// Creates and returns a new certificates storage. You should generally use your
// storage class's specialized creation function, which is usually easier to use.
//
//  allocator: The allocator to use or NULL for the default allocator.
//        cls: The storage class to create. Can't be NULL.
//       info: All info needed by the class for the initialization. This pointer
//             is passed unmodified to the class's init function.
//   outError: If an initialization error had occured and |outError| is not NULL,
//             it'll be filled with the error code.
extern PoloCertificatesStorageRef PoloCertificatesStorageCreate(
  PoloMemoryAllocatorRef allocator,
  PoloCertificatesStorageClassRef cls,
  void *info,
  int *outError);

// Returns a human readable reason for a given error, or NULL if no reason is
// available. |storage| The certificates storage that returned the error. Can't
// be NULL.
extern const char * PoloCertificatesStorageGetErrorReason(
  PoloCertificatesStorageRef storage,
  int errorCode);
// Adds a given X509 certificate to the storage. |storage| and |certificate|
// must point to valid objects.
// If the certificate already exists in the storage this function returns
// kPoloCertificatesStorageErrCertificateAlreadyExists.
extern int PoloCertificatesStorageAddCertificate(
  PoloCertificatesStorageRef storage,
  X509 *certificate);
// Removes a given X509 certificate from the storage. |storage| and
// |certificate| must point to valid objects. If the storage doesn't contain
// the given certificate kPoloCertificatesStorageErrUnknownCertificate will be
// returned.
extern int PoloCertificatesStorageRemoveCertificate(
  PoloCertificatesStorageRef storage,
  X509 *certificate);
// Sets the trust storage of the given SSL context to all certificates of the
// storage. |storage| and |sslContext| can't be NULL.
// Returns kPoloCertificatesStorageErrOperationNotSupported if the sotrage
// stores cerficiates in its own format. In this case you should use
// PoloCertificatesStorageVerifyCertificate() to verify each certificate.
extern int PoloCertificatesStorageSetTrustStore(
  PoloCertificatesStorageRef storage,
  SSL_CTX *sslContext);
// Returns 1 if PoloCertificatesStorageSetTrustStore() is supported by the
// given storage, 0 if not.
extern int PoloCertificatesStorageCanSetTrustStore(
  PoloCertificatesStorageRef storage);
// Verifies that a given certificate is trusted. Returns
// kPoloCertificatesStorageErrNone if the certificate is trusted.
extern int PoloCertificatesStorageVerifyCertificate(
  PoloCertificatesStorageRef storage,
  X509 *cerficiate);
// Returns 1 if PoloCertificatesStorageVerifyCertificate() is supported by the
// given storage, 0 if not.
extern int PoloCertificatesStorageCanVerifyCertificate(
  PoloCertificatesStorageRef storage);

// A certificates storage class that stores certificates unencrypted in a
// directory on disk. Each certificate is stored in its own file.
extern const PoloCertificatesStorageClassRef PoloCertificatesStorageDiskClass;

// Creates and returns a certificates storage that stores certificates in the
// given directory path. |directory| must be a full path and must already exist.
extern PoloCertificatesStorageRef PoloCertificatesStorageCreateDiskStorage(
  PoloMemoryAllocatorRef allocator,
  const char *directory,
  int *outError);

// Returns the directory of the given disk certificates storage.
extern int PoloCertificatesStorageDiskGetDirectory(
  PoloCertificatesStorageRef storage,
  const char **outDirectory);

// General error codes. Codes up to 200 (including) are reserved.
enum {
  // Success
  kPoloCertificatesStorageErrNone = 0,
  // A generic internal error
  kPoloCertificatesStorageErrInternal = 1,
  // An invalid argument was given to the function
  kPoloCertificatesStorageErrInvalidArgument = 2,
  // The operation is not supported by the implementation
  kPoloCertificatesStorageErrOperationNotSupported = 3,
  kPoloCertificatesStorageErrCertificateAlreadyExists = 100,
  kPoloCertificatesStorageErrUnknownCertificate = 101,
  // Storage with invalid class was passed
  kPoloCertificatesStorageErrInvalidClass = 102,
};

// Disk storage errors
enum {
  // Can't create file (usually in the storage directory)
  kPoloCertificatesStorageDiskErrCanNotCreateFile = 201,
  // Can't write certificate's PEM to the designated file
  kPoloCertificatesStorageDiskErrCanNotWritePEMToFile = 202,
  // Internal rename(2) operation failed
  kPoloCertificatesStorageDiskErrCanNotRenameFile = 203,
  // Internal unlink(2) operation failed. If returned from
  // PoloCertificatesStorageRemoveCertificate() it means the remove failed and
  // the certificate is still in the storage.
  kPoloCertificatesStorageDiskErrCanNotUnlinkFile = 204,
  // The passed storage directory does not exist
  kPoloCertificatesStorageDiskErrDirectoryUnavailable = 205
};


extern struct PoloClass *PoloClassGetCertificatesStorageClass(void);

#ifdef  __cplusplus
}
#endif
#endif
