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

#include "PoloClient.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <openssl/err.h>
#include <assert.h>
#include <sys/socket.h>


void PoloInit(void) {
  static int32_t initialized = 0;
  if (POLO_ATOMIC_COMPARE_AND_SWAP(&initialized, 0, 1)) {
    SSL_load_error_strings();
    ERR_load_BIO_strings();
    OpenSSL_add_all_algorithms();
    OpenSSL_add_all_ciphers();
    SSL_library_init();
  }
}

#pragma mark PoloClient

#define POLO_CLIENT_GENERATED_ID 0x1

void PoloClientDestroy(PoloClientRef client) {
  if (client->certificate)
    X509_free(client->certificate);

  if (client->privateKey)
    EVP_PKEY_free(client->privateKey);

  if (client->serviceName)
    PoloMemoryAllocatorStrongResign(client->serviceName);

  if (client->clientName)
    PoloMemoryAllocatorStrongResign(client->clientName);
}

struct PoloClass PoloClassClient = {
  NULL, // No bridge
  NULL,
  sizeof(struct polo_client),
  NULL,
  (void *)PoloClientDestroy,
  NULL
};

struct PoloClass *PoloClassGetClientClass(void) {
  return &PoloClassClient;
}

PoloClientRef PoloClientCreate(PoloMemoryAllocatorRef allocator) {
  PoloClientRef client = PoloAlloc(allocator,
                                   0,
                                   PoloClassGetClientClass());
  return client;
}

const char *PoloClientGetServiceName(PoloClientRef client) {
  return client->serviceName;
}

void PoloClientSetServiceName(PoloClientRef client, const char *serviceName) {
  if (client->serviceName)
    PoloMemoryAllocatorStrongResign(client->serviceName);

  if (serviceName) {
    size_t len = strlen(serviceName);
    PoloMemoryAllocatorRef allocator;
    allocator = PoloMemoryAllocatorGetAllocatorForPtr(client);
    client->serviceName = PoloMemoryAllocatorCopy(allocator,
                                                  (void *)serviceName,
                                                  sizeof(char) * (len + 1));
  } else {
    client->serviceName = NULL;
  }
}

const char *PoloClientGetClientName(PoloClientRef client) {
  return client->clientName;
}

void PoloClientSetClientName(PoloClientRef client, const char *clientName) {
  if (client->clientName)
    PoloMemoryAllocatorStrongResign(client->clientName);

  if (clientName) {
    size_t len = strlen(clientName);
    PoloMemoryAllocatorRef allocator;
    allocator = PoloMemoryAllocatorGetAllocatorForPtr(client);
    client->clientName = PoloMemoryAllocatorCopy(allocator,
                                                 (void *)clientName,
                                                 sizeof(char) * (len + 1));
  } else {
    client->clientName = NULL;
  }
}

X509 *PoloClientGetCertificate(PoloClientRef client) {
  return client->certificate;
}

void PoloClientSetCertificate(PoloClientRef client, X509 *certificate) {
  if (client->certificate)
    X509_free(client->certificate);

  client->certificate = certificate;
}

int PoloClientGeneratedID(PoloClientRef client) {
  return client->flags & POLO_CLIENT_GENERATED_ID;
}

void PoloClientSetGeneratedIDFlag(PoloClientRef client, int flag) {
  if (flag)
    client->flags |= POLO_CLIENT_GENERATED_ID;
  else
    client->flags ^= POLO_CLIENT_GENERATED_ID;
}

int PoloClientGenerateIdentity(PoloClientRef client,
                                  const char *subjectName) {
  // Make sure we got everything we need
  assert(client != NULL);
  assert(subjectName != NULL);
  assert(strlen(subjectName) > 0);

  X509 *cert = X509_new();
  EVP_PKEY *key = EVP_PKEY_new();
  RSA *rsa;
  X509_NAME *name;
  int result = POLO_ERR_OK;
  int serial = 0;
  int days = 356; // We issue a certificate for 1 year
  int bits = 1025;

  rsa = RSA_generate_key(bits, RSA_F4, NULL, NULL);
  if (!EVP_PKEY_assign_RSA(key, rsa)) {
    result = POLO_ERR_INTERNAL;
    goto err;
  }
  rsa = NULL;

  X509_set_version(cert, 2);
  ASN1_INTEGER_set(X509_get_serialNumber(cert), serial);
  X509_gmtime_adj(X509_get_notBefore(cert), 0);
  X509_gmtime_adj(X509_get_notAfter(cert), (long)60*60*24*days);
  X509_set_pubkey(cert, key);

  name = X509_get_subject_name(cert);

  X509_NAME_add_entry_by_NID(name,
                             NID_commonName,
                             MBSTRING_ASC,
                             (unsigned char *)subjectName,
                             -1,
                             -1,
                             0);

  // Its self signed so set the issuer name to be the same as the subject.
  X509_set_issuer_name(cert, name);

  if (!X509_sign(cert, key, EVP_sha256())) {
    result = POLO_ERR_INTERNAL;
    goto err;
  }

  PoloClientSetCertificate(client, cert);
  PoloClientSetPrivateKey(client, key);
  PoloClientSetGeneratedIDFlag(client, 1);
  return POLO_ERR_OK;
err:
  X509_free(cert);
  EVP_PKEY_free(key);
  return result;
}

EVP_PKEY *PoloClientGetPrivateKey(PoloClientRef client) {
  return client->privateKey;
}

void PoloClientSetPrivateKey(PoloClientRef client, EVP_PKEY *key) {
  if (client->privateKey)
    EVP_PKEY_free(client->privateKey);
  client->privateKey = key;
}

int PoloClientIsValid(PoloClientRef client) {
  if (!client->certificate)
    return POLO_ERR_CLIENT_MISSING_CERTIFICATE;

  if (!client->privateKey)
    return POLO_ERR_CLIENT_MISSING_PRIVATE_KEY;

  if (!client->serviceName)
    return POLO_ERR_CLIENT_MISSING_SERVICE_NAME;

  return POLO_ERR_OK;
}

#pragma mark -
#pragma mark PoloConnection

enum {
  PoloConnectionStatusOffline = 0,
  PoloConnectionStatusLocked = 1,
  PoloConnectionStatusConnected,
  PoloConnectionStatusPairing,
  PoloConnectionStatusWaitingForSecret
};

int PoloConnectionCloseInternal(PoloConnectionRef connection);
extern void *PoloConnectionPairingThread(void *connectionPtr);

// ObjC bridge
#ifdef __APPLE__
extern void PoloObjCConnectionInit(PoloConnectionRef connection);
extern void PoloObjCConnectionDestroy(PoloConnectionRef connection);
extern void PoloObjCConnectionClose(PoloConnectionRef connection);
extern void PoloObjCConnectionDidOpen(PoloConnectionRef connection);
#endif

const PoloConnectionEncodingsSet PoloConnectionEncodingsNone = { 0, NULL };

PoloType PoloConnectionInit(PoloType ptr) {
  PoloConnectionRef connection = (PoloConnectionRef)ptr;

  connection->pairingPort = 9700;
  pthread_mutex_init(&connection->peerNameMutex, NULL);
  pthread_mutex_init(&connection->secretMutex, NULL);
  pthread_cond_init(&connection->secretConditionLock, NULL);
#ifdef __APPLE__
  PoloObjCConnectionInit(connection);
#endif
  return (PoloType)connection;
}

void PoloConnectionDestroy(PoloType ptr) {
  PoloConnectionRef connection = (PoloConnectionRef)ptr;

  PoloConnectionClose(connection);
#ifdef __APPLE__
  PoloObjCConnectionDestroy(connection);
#endif
  pthread_cond_destroy(&connection->secretConditionLock);
  pthread_mutex_destroy(&connection->secretMutex);
  PoloMemoryAllocatorStrongResign(connection->peerName);
  pthread_mutex_destroy(&connection->peerNameMutex);
  PoloMemoryAllocatorStrongResign(connection->host);
  PoloRelease(connection->certificatesStorage);
  PoloRelease(connection->client);
}

struct PoloClass PoloClassConnection = {
  NULL, // No bridge
  NULL,
  sizeof(struct polo_connection),
  PoloConnectionInit,
  PoloConnectionDestroy,
  NULL
};

struct PoloClass *PoloClassGetConnectionClass(void) {
  return &PoloClassConnection;
}

PoloConnectionRef PoloConnectionCreate(PoloMemoryAllocatorRef allocator) {
  return (PoloConnectionRef)PoloAlloc(allocator,
                                      0,
                                      PoloClassGetConnectionClass());
}

#pragma mark Accessors

void PoloConnectionSetClient(PoloConnectionRef connection,
                             PoloClientRef client) {
  PoloRelease(connection->client);
  connection->client = PoloRetain(client);
}

PoloClientRef PoloConnectionGetClient(PoloConnectionRef connection) {
  return connection->client;
}

void PoloConnectionSetInputEncodings(PoloConnectionRef connection,
                                     PoloConnectionEncodingsSet encodings) {
  PoloMemoryAllocatorRef allocator = PoloMemoryAllocatorGetAllocatorForPtr(connection);

  if (connection->inputEncodings.count > 0)
    PoloMemoryAllocatorStrongResign(connection->inputEncodings.entries);

  if (encodings.count > 0) {
    size_t length = sizeof(PoloConnectionEncoding) * encodings.count;
    connection->inputEncodings.count = encodings.count;
    connection->inputEncodings.entries = PoloMemoryAllocatorCopy(allocator,
                                                                 encodings.entries,
                                                                 length);
  } else {
    connection->inputEncodings = PoloConnectionEncodingsNone;
  }
}

PoloConnectionEncodingsSet
PoloConnectionGetInputEncodings(PoloConnectionRef connection) {
  return connection->inputEncodings;
}

void PoloConnectionSetOutputEncodings(PoloConnectionRef connection,
                                      PoloConnectionEncodingsSet encodings) {
  PoloMemoryAllocatorRef allocator = PoloMemoryAllocatorGetAllocatorForPtr(connection);

  if (connection->outputEncodings.count > 0)
    PoloMemoryAllocatorStrongResign(connection->outputEncodings.entries);

  if (encodings.count > 0) {
    size_t length = sizeof(PoloConnectionEncoding) * encodings.count;
    connection->outputEncodings.count = encodings.count;
    connection->outputEncodings.entries = PoloMemoryAllocatorCopy(allocator,
                                                                  encodings.entries,
                                                                  length);
  } else {
    connection->outputEncodings = PoloConnectionEncodingsNone;
  }
}

PoloConnectionEncodingsSet
PoloConnectionGetOutputEncodings(PoloConnectionRef connection) {
  return connection->outputEncodings;
}

void PoloConnectionSetPreferredRole(PoloConnectionRef connection,
                                    PoloConnectionRole role) {
  connection->preferredRole = role;
}

PoloConnectionEncoding PoloConnectionGetEncoding(PoloConnectionRef connection) {
  return connection->encoding;
}

void PoloConnectionSetEncoding(PoloConnectionRef connection,
                               PoloConnectionEncoding encoding) {
  connection->encoding = encoding;
}

PoloConnectionRole
PoloConnectionGetPreferredRole(PoloConnectionRef connection) {
  return connection->preferredRole;
}

PoloConnectionRole PoloConnectionGetRole(PoloConnectionRef connection) {
  return connection->role;
}

void PoloConnectionSetRole(PoloConnectionRef connection,
                           PoloConnectionRole role) {
  connection->role = role;
}

void
PoloConnectionSetCertificatesStorage(PoloConnectionRef connection,
                                     PoloCertificatesStorageRef storage) {
  PoloRelease(connection->certificatesStorage);
  connection->certificatesStorage = PoloRetain(storage);
}

PoloCertificatesStorageRef
PoloConnectionGetCertificatesStorage(PoloConnectionRef connection) {
  return connection->certificatesStorage;
}

int PoloConnectionSetHost(PoloConnectionRef connection, const char *host) {
  PoloMemoryAllocatorRef allocator = PoloMemoryAllocatorGetAllocatorForPtr(connection);

  if (host) {
    size_t len = strlen(host);
    int i;
    for (i = 0; i < len; ++i) {
      if (host[i] == ':')
        return POLO_ERR_BAD_ARGUMENT;
    }
  }

  if (connection->host)
    PoloMemoryAllocatorStrongResign((void *)connection->host);
  size_t copyLen = (strlen(host) + 1) * sizeof(char);
  connection->host = host ? PoloMemoryAllocatorCopy(allocator,
                                                    (void *)host,
                                                    copyLen)
                          : NULL;
  return POLO_ERR_OK;
}

const char *PoloConnectionGetHost(PoloConnectionRef connection) {
  return connection->host;
}

void PoloConnectionSetPort(PoloConnectionRef connection, int port) {
  connection->port = port;
}

int PoloConnectionGetPort(PoloConnectionRef connection) {
  return connection->port;
}

void PoloConnectionSetPairingPort(PoloConnectionRef connection, int port) {
  connection->pairingPort = port;
}

int PoloConnectionGetPairingPort(PoloConnectionRef connection) {
  return connection->pairingPort;
}

BIO *PoloConnectionGetBIO(PoloConnectionRef connection) {
  return connection->bio;
}

const char *PoloConnectionCopyPeerName(PoloConnectionRef connection) {
  const char *name;

  pthread_mutex_lock(&connection->peerNameMutex);
  if (connection->peerName) {
    size_t len = strlen(connection->peerName);
    name = calloc(len + 1, sizeof(char));
    memcpy((void *)name, (void *)connection->peerName, len * sizeof(char));
  } else {
    name = NULL;
  }
  pthread_mutex_unlock(&connection->peerNameMutex);
  return name;
}

void PoloConnectionSetPeerName(PoloConnectionRef connection,
                               const char *str) {
  PoloMemoryAllocatorRef allocator = PoloMemoryAllocatorGetAllocatorForPtr(connection);

  pthread_mutex_lock(&connection->peerNameMutex);

  const char *oldName = connection->peerName;
  size_t copyLen = (strlen(str) + 1) * sizeof(char);
  const char *newName = str ? PoloMemoryAllocatorCopy(allocator,
                                                      (void *)str,
                                                      copyLen)
                            : NULL;

  connection->peerName = newName;

  if (oldName)
    PoloMemoryAllocatorStrongResign(connection->peerName);
  pthread_mutex_unlock(&connection->peerNameMutex);
}

void
PoloConnectionSetCallbacks(PoloConnectionRef connection,
                           struct PoloConnectionCallbacks *callbacks) {
  connection->callbacks = *callbacks;
}

extern struct PoloConnectionCallbacks *
PoloConnectionGetCallbacks(PoloConnectionRef connection) {
  return &connection->callbacks;
}

#pragma mark Protocol Logic

// This macro checks the connection is valid and is ready to start a
// connection/pairing. If not it returns an error.
#define ASSERT_VALID_CONNECTION(connection) \
do {\
  int __clientState = PoloClientIsValid(PoloConnectionGetClient(connection));\
  if (__clientState != POLO_ERR_OK)\
    return __clientState;\
  if (PoloConnectionGetHost(connection) == NULL)\
    return POLO_ERR_MISSING_HOST;\
  if (!POLO_ATOMIC_COMPARE_AND_SWAP(&connection->status,\
                                    PoloConnectionStatusOffline,\
                                    PoloConnectionStatusLocked))\
    return POLO_ERR_INTERNAL;\
} while(0)

static void PoloConnectionSetupSSLContext(PoloConnectionRef connection) {
  PoloCertificatesStorageRef certificatesStorage;
  PoloClientRef client = PoloConnectionGetClient(connection);

  if (connection->sslContext)
    SSL_CTX_free(connection->sslContext);

  connection->sslContext = SSL_CTX_new(TLSv1_method());
  SSL_CTX_use_certificate(connection->sslContext,
                          PoloClientGetCertificate(client));
  SSL_CTX_use_PrivateKey(connection->sslContext,
                         PoloClientGetPrivateKey(client));
  certificatesStorage = PoloConnectionGetCertificatesStorage(connection);

  if (certificatesStorage &&
      PoloCertificatesStorageCanSetTrustStore(certificatesStorage)) {
    PoloCertificatesStorageSetTrustStore(certificatesStorage,
                                         connection->sslContext);
  }
}

int PoloConnectionStartPairing(PoloConnectionRef connection) {
  BIO *bio;
  int port;

  ASSERT_VALID_CONNECTION(connection);

  PoloConnectionSetupSSLContext(connection);
  bio = BIO_new_ssl_connect(connection->sslContext);

  connection->bio = bio;
  BIO_set_conn_hostname(bio, connection->host);
  port = PoloConnectionGetPairingPort(connection);
  BIO_set_conn_int_port(bio, &port);
  BIO_set_nbio(bio, 0); // Make sure we're using blocking I/O

  if (BIO_do_connect(bio) <= 0) {
    PoloConnectionCloseInternal(connection);
    return POLO_ERR_CONNECTION_FAILURE;
  } else {
    // Ignore SIGPIPE
    int socket;
    int on = 1;
    BIO_get_fd(bio, &socket);
    setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));

    // Create our pairing thread
    pthread_attr_t attr;

    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    pthread_create(&connection->pairingThread,
                   &attr,
                   PoloConnectionPairingThread,
                   connection);
    pthread_attr_destroy(&attr);
    if (POLO_ATOMIC_COMPARE_AND_SWAP(&connection->status,
                                     PoloConnectionStatusLocked,
                                     PoloConnectionStatusPairing)) {
      return POLO_ERR_OK;
    } else {
      PoloConnectionCloseInternal(connection);
      return POLO_ERR_INTERNAL;
    }
  }
}

int select_and_wait(BIO *bio, int timeout) {
  int fd;
  fd_set readfds;
  fd_set writefds;
  struct timeval tv;

  fd = BIO_get_fd(bio, NULL);
  if (fd == -1) {
    return -1;
  }

  FD_ZERO(&readfds);
  FD_ZERO(&writefds);

  // Check if read operation should be retried.
  if (BIO_should_read(bio)) {
    FD_SET(fd, &readfds);
  } else if (BIO_should_write(bio) || (BIO_should_io_special(bio) &&
      (BIO_get_retry_reason(bio) == BIO_RR_CONNECT))) {
    // No reads, so we are waiting on write.
    FD_SET(fd, &writefds);
  }

  tv.tv_sec = timeout;
  tv.tv_usec = 0;
  return select(fd + 1, &readfds, &writefds, NULL, &tv);
}

#define POLO_CONNECT_TIMEOUT_MS 5

int PoloConnectionOpen(PoloConnectionRef connection) {
  SSL *ssl;
  int port;
  BIO *bio;
  int err;

  ASSERT_VALID_CONNECTION(connection);

  PoloConnectionSetupSSLContext(connection);
  bio = BIO_new_ssl_connect(connection->sslContext);
  connection->bio = bio;
  BIO_get_ssl(bio, &ssl);
  SSL_set_mode(ssl, SSL_MODE_AUTO_RETRY);
  // Set underlying socket to non-blocking mode.
  BIO_set_nbio(bio, 1);
  BIO_set_conn_hostname(bio, PoloConnectionGetHost(connection));
  port = PoloConnectionGetPort(connection);
  BIO_set_conn_int_port(bio, &port);

  while (1) {
    /* Connect to server and do handshake. */
    if (BIO_do_connect(bio) == 1) {  /* Connection established. */
      break;
    }

    /* Check if there is hard error. */
    if (!BIO_should_retry(bio)) {
      unsigned long error = ERR_get_error();
      PoloConnectionCloseInternal(connection);
      if (ERR_GET_LIB(error) == ERR_LIB_SSL) {
        return POLO_ERR_NOT_PAIRED;
      } else {
        return POLO_ERR_CONNECTION_FAILURE;
      }
    }

    err = select_and_wait(bio, POLO_CONNECT_TIMEOUT_MS);

    if (err <= 0) { /* FYI: err == 0 is timeout */
      PoloConnectionCloseInternal(connection);
      return POLO_ERR_CONNECTION_FAILURE;
    }
  }

  int needsPairing = 0;
  PoloCertificatesStorageRef certsStorage;
  certsStorage = PoloConnectionGetCertificatesStorage(connection);

  if (certsStorage) {
    if (PoloCertificatesStorageCanVerifyCertificate(certsStorage)) {
      X509 *certificate = SSL_get_peer_certificate(ssl);
      needsPairing = PoloCertificatesStorageVerifyCertificate(certsStorage,
                                                              certificate) !=
                     kPoloCertificatesStorageErrNone;
    } else {
      long err = SSL_get_verify_result(ssl);
      //printf("%ld\n", err);
      needsPairing = err != X509_V_OK;
    }
  }
  if (needsPairing) {
    PoloConnectionCloseInternal(connection);
    return POLO_ERR_NOT_PAIRED;
  }

  // Ignore SIGPIPE
  int socket;
  int on = 1;
  BIO_get_fd(bio, &socket);
  setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));

  if (POLO_ATOMIC_COMPARE_AND_SWAP(&connection->status,
                                   PoloConnectionStatusLocked,
                                   PoloConnectionStatusConnected)) {
#ifdef __APPLE__
    PoloObjCConnectionDidOpen(connection);
#endif
    return POLO_ERR_OK;
  } else {
    // If we got here, we're probably going to crash
    PoloConnectionCloseInternal(connection);
    return POLO_ERR_INTERNAL;
  }
}

int PoloConnectionCloseInternal(PoloConnectionRef connection) {
  if (connection->bio && connection->sslContext) {
    connection->status = PoloConnectionStatusLocked;
    BIO_free(connection->bio);
    connection->bio = NULL;
    SSL_CTX_free(connection->sslContext);
    connection->sslContext = NULL;
    connection->status = PoloConnectionStatusOffline;
    return POLO_ERR_OK;
  } else {
    return POLO_ERR_INTERNAL;
  }
}

int PoloConnectionClose(PoloConnectionRef connection) {
  int err;

  if (connection->status == PoloConnectionStatusPairing ||
      connection->status == PoloConnectionStatusWaitingForSecret) {
    err = PoloConnectionCancelPairing(connection);
  } else if (connection->status == PoloConnectionStatusConnected) {
    err = PoloConnectionCloseInternal(connection);
  } else {
    err = POLO_ERR_INTERNAL;
  }

#ifdef __APPLE__
  if (err == POLO_ERR_OK)
    PoloObjCConnectionClose(connection);
#endif
  return err;
}

void *PoloConnectionParseHexadecimalSecret(const char *secretStr,
                                           size_t *outSize) {
  size_t strLength = strlen(secretStr);
  size_t secretLength = strLength;
  uint8_t *secret;

  if (strLength % 4 != 0)
    secretLength += 4 - strLength % 4;

  secretLength /= 2;  // each character is 4 bits
  secret = calloc(secretLength, sizeof(uint8_t));
  int i = 0, j = 0;
  // Scan all characters and read them as hex values. All values are between
  // 0x0 and 0xF. We then combine each two values to a byte and store it in
  // |secret|.
  while (i < strLength) {
    unsigned int value = 0;

    char str[2] = { '\0', '\0' };
    str[0] = toupper(secretStr[i]);
    sscanf(str, "%x", &value);

    if (i + 1 < strLength) {
      unsigned int val2 = 0;

      str[0] = toupper(secretStr[i + 1]);
      sscanf(str, "%x", &val2);
      value = value << 4 | val2;
      ++i;
    }

    secret[j] = (uint8_t)value;
    ++j;
    ++i;
  };

  *outSize = secretLength;
  return secret;
}

int PoloConnectionContinuePairingWithStringSecret(PoloConnectionRef connection,
                                                   const char *secretStr) {
  PoloConnectionEncoding encoding = PoloConnectionGetEncoding(connection);
  void *secret = NULL;
  size_t secretLength = 0;
  int result = POLO_ERR_OK;

  switch (encoding.type) {
    case PoloConnectionEncodingHexadecimal:
      secret = PoloConnectionParseHexadecimalSecret(secretStr, &secretLength);
      break;

    case PoloConnectionEncodingAlphanumeric:
    case PoloConnectionEncodingNumeric:
    case PoloConnectionEncodingQRCode:
      result = POLO_ERR_SECRET_UNSUPPORTED_ENCODING;
      break;

    default:
      result = POLO_ERR_SECRET_UNKNOWN_ENCODING;
      break;
  }

  if (secret) {
    result = PoloConnectionContinuePairingWithSecret(connection,
                                                     secretLength,
                                                     secret);
    free(secret);
  }

  return result;
}

size_t PoloGetSecretLengthForEncoding(PoloConnectionEncoding encoding) {
  switch (encoding.type) {
    case PoloConnectionEncodingHexadecimal: {
      size_t secretLength = encoding.symbolLength;

      if (secretLength % 4 != 0)
        secretLength += 4 - secretLength % 4;

      return secretLength /= 2; // each character is 4 bits
    }

    default:
      return 0;
  }
}

// Computes and returns the alpha part of the secret. You're responsible for
// freeing the returned buffer. The returned data is of size |secretLength|/2.
// If you want to compute the full secret you need to append |nonce| after the
// result of this function.
void *PoloComputeSecretAlpha(size_t secretLength,
                             X509 *outputPeerCert,
                             X509 *inputPeerCert,
                             void *nonce,
                             size_t *outLength) {
  RSA *outputKey = EVP_PKEY_get1_RSA(X509_get_pubkey(outputPeerCert));
  RSA *inputKey = EVP_PKEY_get1_RSA(X509_get_pubkey(inputPeerCert));
  // Get the sizes of the modulus and exponent of both keys
  size_t onSize = BN_num_bytes(outputKey->n);
  size_t oeSize = BN_num_bytes(outputKey->e);
  size_t inSize = BN_num_bytes(inputKey->n);
  size_t ieSize = BN_num_bytes(inputKey->e);
  size_t buffSize = onSize + oeSize + inSize + ieSize + secretLength / 2;
  unsigned char *buff = (unsigned char *)malloc(buffSize);

  // Concatenate everything together. It goes like this:
  // a = output device which generated the nonce
  // b = input device (didn't generate the nonce)
  // M = modulus
  // E = exponent
  // Ma | Ea | Mb | Eb | nonce
  size_t s = 0;
  BN_bn2bin(outputKey->n, buff);
  s += onSize;
  BN_bn2bin(outputKey->e, buff + onSize);
  s += oeSize;
  BN_bn2bin(inputKey->n, buff + onSize + oeSize);
  s += inSize;
  BN_bn2bin(inputKey->e, buff + onSize + oeSize + inSize);
  s += ieSize;
  memcpy((void *)(buff + buffSize - secretLength / 2),
         nonce,
         secretLength / 2);

  // Compute a SHA256 digest of our buffer
  unsigned char digest[SHA256_DIGEST_LENGTH];
  SHA256(buff, buffSize, digest);

  void *secret = malloc(SHA256_DIGEST_LENGTH);
  memcpy(secret, digest, SHA256_DIGEST_LENGTH);
  *outLength = SHA256_DIGEST_LENGTH;
  free(buff);
  return secret;
}

// Checks a given secret for the given connection.
// If secret is of wrong length, returns POLO_ERR_SECRET_WRONG_SECRET_LENGTH.
// If the secret is wrong, returns POLO_ERR_WRONG_SECRET.
// Returns POLO_ERR_PAIRING_BAD_SECRET if |secret| is NULL.
// If the secret appears to be valid, returns POLO_ERR_OK.
//
// On return, if |outAlphaLen| is not NULL, it'll be set to the size of the
// alpha part of the secret.
int PoloConnectionCheckSecret(PoloConnectionRef connection,
                              const void *secret,
                              size_t secretLength,
                              size_t *outAlphaLen,
                              void **outAlpha) {
  PoloConnectionEncoding encoding = PoloConnectionGetEncoding(connection);
  if (PoloGetSecretLengthForEncoding(encoding) != secretLength)
    return POLO_ERR_SECRET_WRONG_SECRET_LENGTH;

  if (!secret)
    return POLO_ERR_PAIRING_BAD_SECRET;

  int retCode = POLO_ERR_OK;
  PoloClientRef client = PoloConnectionGetClient(connection);
  BIO *bio = PoloConnectionGetBIO(connection);
  SSL *ssl;
  BIO_get_ssl(bio, &ssl);
  X509 *peerCertificate = SSL_get_peer_certificate(ssl);
  void *nonce = (void *)(((uint8_t *)secret) + (secretLength / 2));
  size_t alphaLen;
  void *secretAlpha = PoloComputeSecretAlpha(secretLength,
                                             PoloClientGetCertificate(client),
                                             peerCertificate,
                                             nonce,
                                             &alphaLen);
  if (memcmp(secret, secretAlpha, secretLength / 2))
    retCode = POLO_ERR_WRONG_SECRET;

  if (outAlpha)
    *outAlpha = secretAlpha;
  else
    free(secretAlpha);
  if (outAlphaLen)
    *outAlphaLen = alphaLen;

  return retCode;
}

int PoloConnectionContinuePairingWithSecret(PoloConnectionRef connection,
                                            size_t length,
                                            const void *secret) {
  if (connection->secret != NULL)
    return POLO_ERR_INTERNAL;

  size_t alphaLen;
  void *alpha;
  int retCode = PoloConnectionCheckSecret(connection,
                                          secret,
                                          length,
                                          &alphaLen,
                                          &alpha);
  if (retCode != POLO_ERR_OK)
    return retCode;

  PoloMemoryAllocatorRef allocator;
  allocator = PoloMemoryAllocatorGetAllocatorForPtr(connection);

  pthread_mutex_lock(&connection->secretMutex);
  connection->secret = PoloMemoryAllocatorCopy(allocator,
                                               (void *)alpha,
                                               alphaLen);
  connection->secretLength = alphaLen;
  pthread_cond_signal(&connection->secretConditionLock);
  pthread_mutex_unlock(&connection->secretMutex);
  free(alpha);
  return POLO_ERR_OK;
}

int PoloConnectionCancelPairing(PoloConnectionRef connection) {
  if (POLO_ATOMIC_COMPARE_AND_SWAP(&connection->status,
                                   PoloConnectionStatusPairing,
                                   PoloConnectionStatusLocked)) {
    return pthread_cancel(connection->pairingThread) != 0 ? POLO_ERR_INTERNAL
                                                          : POLO_ERR_OK;
  } else if (POLO_ATOMIC_COMPARE_AND_SWAP(&connection->status,
                                          PoloConnectionStatusWaitingForSecret,
                                          PoloConnectionStatusLocked)) {
    int err = pthread_cancel(connection->pairingThread);
    pthread_mutex_lock(&connection->secretMutex);
    pthread_cond_signal(&connection->secretConditionLock);
    pthread_mutex_unlock(&connection->secretMutex);
    return err != 0 ? POLO_ERR_INTERNAL : POLO_ERR_OK;
  } else {
    return POLO_ERR_NOT_PAIRING;
  }
}

int PoloConnectionWrite(PoloConnectionRef connection,
                        const void *buf,
                        size_t len) {
  int err;
  BIO *bio = PoloConnectionGetBIO(connection);

  if (!bio)
    return POLO_ERR_NOT_CONNECTED;

  err = BIO_write(PoloConnectionGetBIO(connection), buf,len);
  if (err <= 0) {
    return POLO_ERR_CONNECTION_GENERIC;
  } else {
    return POLO_ERR_OK;
  }
}

int PoloConnectionRead(PoloConnectionRef connection,
                       void *buf,
                       size_t len) {
  if (BIO_read(PoloConnectionGetBIO(connection), buf, len) <= 0)
    return POLO_ERR_CONNECTION_GENERIC;
  else
    return POLO_ERR_OK;
}

int PoloConnectionIsConnected(PoloConnectionRef connection) {
  return connection->status == PoloConnectionStatusConnected;
}

int PoloConnectionIsWaitingForSecret(PoloConnectionRef connection) {
  return connection->status == PoloConnectionStatusWaitingForSecret;
}
