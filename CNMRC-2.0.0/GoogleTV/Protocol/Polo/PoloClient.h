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
/*
 *  Polo is a pairing protocol over IP that works similar to the Bluetooth
 *  pairing process. It was built for pairing a remote with a Google-TV device,
 *  but it can be used by various types of applications.
 *  This implementation aims to be as portable as possible while still being
 *  high level enough to abstract the details of the protocol itself. The
 *  implementation has two dependencies: OpenSSL and the protobuf C++ runtime.
 *
 *  For more information about the protocol you can read the protocol design
 *  doc at https://docs.google.com/a/google.com/Doc?docid=0ASx2U1c-9SrsYWZ2aGRzd3hqeF8zYzh0OXBnZjQ&hl=en
 *  and the protocol implementation at https://docs.google.com/a/google.com/Doc?docid=0ASx2U1c-9SrsYWZ2aGRzd3hqeF8wOXM0ZHZxeGo&hl=en
 *
 *  This implementation was tested only in iOS environment at this point.
 *
 *  TODO(ofri): Release this as open source.
 *
 */

#ifndef HEADER_POLO_CLIENT_H
#define HEADER_POLO_CLIENT_H

#include <openssl/rsa.h>
#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <Polo/PoloCertificatesStorage.h>
#include <stdint.h>
#include <pthread.h>

#ifdef  __cplusplus
extern "C" {
#endif


// Initializes the Polo library. You must call this function before using
// anything else.
// If you're including the ObjC wrappers in our code then this function is
// invoked automatically for you.
extern void PoloInit(void);

#pragma mark PoloClient
// PoloClient represents an application/device that wishes to pair with another
// entity. Each client has its own unique certificate which is used to identify
// it among all other paired entities.
// In addition to its certificate, a client also has a service name and an
// optional client name. The service name is the name of the service to pair
// with. The client name is a descriptive name of the client that will be used
// by other paired entities.
struct polo_client {
  // All fields are private. They are a subject to change at any future version.
  struct PoloBase base;
  X509 *certificate;
  EVP_PKEY *privateKey;
  __strong const char *serviceName;
  __strong const char *clientName;
  uint32_t flags;
};
typedef struct polo_client *PoloClientRef;


// Allocates and returns a new Polo client. The newly created client must be
// properly configured before it can be used with a PoloConnection.
// Configurable fields are:
//   Service Name   Required
//   Client Name    Optional
//   Certificate    Required
//   Private Key    Required
extern PoloClientRef PoloClientCreate(PoloMemoryAllocatorRef allocator);

extern const char *PoloClientGetServiceName(PoloClientRef client);
// Sets the service name of the given client. The service name is the name of
// the service to pair with. The name used should be an established convention
// of the application protocol.
// The service name is required for every client.
// The passed string is copied into the client.
extern void PoloClientSetServiceName(PoloClientRef client,
                                     const char *serviceName);

extern const char *PoloClientGetClientName(PoloClientRef client);
extern void PoloClientSetClientName(PoloClientRef client,
                                    const char *clientName);

// Returns the certificate of the client
extern X509 *PoloClientGetCertificate(PoloClientRef client);
// Sets the certificate of the client. The client takes ownership of the
// certificate and will free it when it's destroyed. This function is intended
// mainly for archiving purposes. No checks
extern void PoloClientSetCertificate(PoloClientRef client,
                                     X509 *certificate);
// Generates a new identity for the given client. It replaces the existing
// private key/certificate pair with a fresh new one.
// Returns 0 on success. Other values are error codes defined in the PoloErr
// enum.
// |client| and |subjectName| must not be NULL and |subjectName| must not be
// an empty string (i.e. just a single NULL char).
extern int PoloClientGenerateIdentity(PoloClientRef client,
                                         const char *subjectName);

// Returns the private key of the given client. Generally you don't need to
// touch the private key, except when archiving the client. When archiving,
// you're responsible in archiving the private key in a secure manner as
// most appropriate for application.
extern EVP_PKEY *PoloClientGetPrivateKey(PoloClientRef client);

// Sets the private key of the client. The client takes ownership of the key
// and frees it when needed.
extern void PoloClientSetPrivateKey(PoloClientRef client, EVP_PKEY *key);

// Returns whether the client is valid and can be used to make a connection.
extern int PoloClientIsValid(PoloClientRef client);

extern struct PoloClass *PoloClassGetClientClass(void);

#pragma mark -
#pragma mark PoloConnection

typedef struct polo_connection *PoloConnectionRef;

enum PoloConnectionEncodingType {
  PoloConnectionEncodingUnknown = 0,
  PoloConnectionEncodingAlphanumeric = 1,
  PoloConnectionEncodingNumeric = 2,
  PoloConnectionEncodingHexadecimal = 3,
  PoloConnectionEncodingQRCode = 4
};

struct PoloConnectionEncoding {
  enum PoloConnectionEncodingType type;
  uint32_t symbolLength;
};
typedef struct PoloConnectionEncoding PoloConnectionEncoding;

// Encodings are sorted by preference. Entry 0 is the preferred encoding.
struct PoloConnectionEncodingsSet {
  size_t count;
  __strong PoloConnectionEncoding *entries;
};
typedef struct PoloConnectionEncodingsSet PoloConnectionEncodingsSet;

extern const PoloConnectionEncodingsSet PoloConnectionEncodingsNone;

enum PoloConnectionRole {
  PoloConnectionRoleUnknown = 0,
  PoloConnectionRoleInput = 1,
  PoloConnectionRoleOutput = 2
};
typedef enum PoloConnectionRole PoloConnectionRole;

struct PoloConnectionCallbacks {
  void *info;
  // This function is called **FROM A SECONDARY THREAD** when the connection is
  // waiting for you to provide the pairing secret. If the other end is already
  // paired, this function won't be called. After this function is called, the
  // connection will wait until you provide the secret using
  // PoloConnectionContinueWithSecret(). If you already have the secret
  // available you should return it and set |length| to the size of it. If you
  // don't have it return NULL.
  //
  // WARNING: If you return NULL then the network thread will attempt to hold
  // an internal condition lock. Don't call PoloConnectionContinueWithSecret()
  // too soon or the thread won't have time to hold the lock and you'll enter
  // a deadlock. Don't call PoloConnectionContinueWithSecret() within the
  // callback.
  void *(*waitingForSecret)(PoloConnectionRef connection,
                            size_t *length,
                            void *info);
  // Called when the pairing process ended, for whatever reason, except
  // cancellation. When cancelled, this callback won't be called.
  // If |status| is POLO_ERR_OK then pairing was successful. Any other code
  // means pairing failed.
  // This function is called **FROM A SECONDARY THREAD**.
  void (*pairingEnded)(PoloConnectionRef connection,
                       int status,
                       void *info);
};

// PoloConnection provides access to encrypted connection with a paired
// device/app combination. It implements the Polo pairing protocol, and sends
// all data encrypted using TLS. The implementation builds on OpenSSL and
// C++ protocol buffers, both of which should be fairly portable.
// If you're coding for Mac OS X or iOS, check out PoloObjC.h which provides
// an easier to use Objective-C wrappers.
struct polo_connection {
  // All fields are private
  struct PoloBase base;
  PoloClientRef client;
  //__strong PoloClientRef client;
  PoloConnectionEncodingsSet inputEncodings;
  PoloConnectionEncodingsSet outputEncodings;
  PoloConnectionEncoding encoding;
  PoloConnectionRole preferredRole;
  PoloConnectionRole role;
  PoloCertificatesStorageRef certificatesStorage;
  //__strong PoloCertificatesStorageRef certificatesStorage;
  SSL_CTX *sslContext;
  BIO *bio;
  struct PoloConnectionCallbacks callbacks;
  const char *host;
  //__strong const char *host;
  int port;
  int pairingPort;
  pthread_mutex_t peerNameMutex;
  const char *peerName;
  pthread_t pairingThread;
  void *secret;
  // IMPLEMENTATION NOTE:
  // This is the length of the secret that should be sent to the other side.
  // The size of |secret| may be larger, but will always be the result of
  // PoloGetSecretLengthForEncoding(PoloConnectionGetEncoding()).
  size_t secretLength;
  pthread_cond_t secretConditionLock;
  pthread_mutex_t secretMutex;
  volatile int32_t status;
#ifdef __APPLE__
  void *objcInfo;
#endif
};

extern PoloConnectionRef PoloConnectionCreate(PoloMemoryAllocatorRef allocator);

// Accessors
extern void PoloConnectionSetClient(PoloConnectionRef connection,
                                    PoloClientRef client);
extern PoloClientRef PoloConnectionGetClient(PoloConnectionRef connection);

extern void PoloConnectionSetInputEncodings(PoloConnectionRef connection,
                                            PoloConnectionEncodingsSet encodings);
extern PoloConnectionEncodingsSet
PoloConnectionGetInputEncodings(PoloConnectionRef connection);

extern void PoloConnectionSetOutputEncodings(PoloConnectionRef connection,
                                             PoloConnectionEncodingsSet encodings);
extern PoloConnectionEncodingsSet
PoloConnectionGetOutputEncodings(PoloConnectionRef connection);

// Returns the agreed encoding of the connection as negotated with the server.
// The result of this function is defined only while pairing and after the
// |waitingForSecret| callback has been called.
extern PoloConnectionEncoding
PoloConnectionGetEncoding(PoloConnectionRef connection);

extern void PoloConnectionSetPreferredRole(PoloConnectionRef connection,
                                           PoloConnectionRole role);
extern PoloConnectionRole
PoloConnectionGetPreferredRole(PoloConnectionRef connection);

// Returns the agreed role of the connection as negotated with the server.
// The result of this function is defined only while pairing and after the
// |waitingForSecret| callback has been called.
extern PoloConnectionRole PoloConnectionGetRole(PoloConnectionRef connection);

// Returns POLO_ERR_BAD_ARGUMENT if |host| is not correctly formatted
extern int PoloConnectionSetHost(PoloConnectionRef connection,
                                 const char *host);
extern const char *PoloConnectionGetHost(PoloConnectionRef connection);

extern void PoloConnectionSetPort(PoloConnectionRef connection, int port);
extern int PoloConnectionGetPort(PoloConnectionRef connection);

extern void PoloConnectionSetPairingPort(PoloConnectionRef connection,
                                         int port);
extern int PoloConnectionGetPairingPort(PoloConnectionRef connection);

// If NULL, the connection will accept any peer and will require pairing only
// if the other side requires it.
extern void
PoloConnectionSetCertificatesStorage(PoloConnectionRef connection,
                                     PoloCertificatesStorageRef storage);
extern PoloCertificatesStorageRef
PoloConnectionGetCertificatesStorage(PoloConnectionRef connection);

extern void
PoloConnectionSetCallbacks(PoloConnectionRef connection,
                           struct PoloConnectionCallbacks *callbacks);

extern struct PoloConnectionCallbacks *
PoloConnectionGetCallbacks(PoloConnectionRef connection);

// Returns the name of the other side. You must free() the returned string.
// This value is only available while pairing and after the |waitingForSecret|
// callback has been called.
extern const char *PoloConnectionCopyPeerName(PoloConnectionRef connection);

// Network operations

// Open a connection with the host. If pairing is needed connection will fail
// and POLO_ERR_NOT_PAIRED will be returned.
// If |connection| is already opened, returns POLO_ERR_INTERNAL.
extern int PoloConnectionOpen(PoloConnectionRef connection);
extern int PoloConnectionClose(PoloConnectionRef connection);

// Starts pairing with the host. If PoloConnectionOpen() returned
// POLO_ERR_NOT_PAIRED, then you must complete pairing before you can connect
// with the host.
int PoloConnectionStartPairing(PoloConnectionRef connection);

// |secret| must not be NULL and must be of the correct length.
// Returns POLO_ERR_OK on success. If an error code has been returned then the
// connection is still waiting for the secret.
extern int
PoloConnectionContinuePairingWithSecret(PoloConnectionRef connection,
                                        size_t length,
                                        const void *secret);

// This is a higher level utility for PoloConnectionContinuePairingWithSecret().
// When acting as an input device, you'll usually get the secret as a string
// from the user. This function parses the given string based on the selected
// encoding of the connection, and uses it as the secret.
// Return codes are the same as for PoloConnectionContinuePairingWithSecret().
extern int
PoloConnectionContinuePairingWithStringSecret(PoloConnectionRef connection,
                                              const char *secret);

// Attempts to cancel pairing. If not pairing, returns POLO_ERR_NOT_PAIRING.
extern int PoloConnectionCancelPairing(PoloConnectionRef connection);

// IO functions for connections. You should use only these functions and not
// the underlying BIO.
extern int PoloConnectionWrite(PoloConnectionRef connection,
                               const void *buf,
                               size_t len);
extern int PoloConnectionRead(PoloConnectionRef connection,
                              void *buf,
                              size_t len);

// Returns the underlying BIO of the connection. Don't touch it while pairing.
// Never manipulate the BIO directly. This function is provided only for the
// purpose of chaining other BIOs to the connection's BIO.
extern BIO *PoloConnectionGetBIO(PoloConnectionRef connection);

extern struct PoloClass *PoloClassGetConnectionClass(void);

// Returns the length, in bytes, of the secret described by the given encoding
// Returns 0 for unknown encoding.
extern size_t PoloGetSecretLengthForEncoding(PoloConnectionEncoding encoding);

// No error (success)
#define POLO_ERR_OK                             0
#define POLO_ERR_GENERIC                        (-1)
// Some internal error had occurred. This usually means you used the API in a
// wrong way.
#define POLO_ERR_INTERNAL                       (-2)
// Generic network error
#define POLO_ERR_CONNECTION_GENERIC             (-3)
#define POLO_ERR_NOT_CONNECTED                  (-4)
#define POLO_ERR_BAD_ARGUMENT                   (-5)
// The connection is not currently in an active pairing process.
#define POLO_ERR_NOT_PAIRING                    (-6)

#define POLO_ERR_SECRET_UNSUPPORTED_ENCODING    1
#define POLO_ERR_SECRET_UNKNOWN_ENCODING        2
// A secret of a wrong length was provided
#define POLO_ERR_SECRET_WRONG_SECRET_LENGTH     3
// The secret provided is wrong and pairing will fail with it.
#define POLO_ERR_WRONG_SECRET                   4

#define POLO_ERR_CONNECTION_FAILURE             10
// If you get this error back from PoloConnectionOpen() then you need to pair
// with the host before you can open a connection with it.
#define POLO_ERR_NOT_PAIRED                     11
// No host defined
#define POLO_ERR_MISSING_HOST                   12
// The client of the connection is not valid
#define POLO_ERR_INVALID_CLIENT                 13

// Invalid client errors
#define POLO_ERR_CLIENT_MISSING_CERTIFICATE     50
#define POLO_ERR_CLIENT_MISSING_PRIVATE_KEY     51
#define POLO_ERR_CLIENT_MISSING_SERVICE_NAME    52

// Pairing errors

// Generic connection error
#define POLO_ERR_PAIRING_CONNECTION_ERROR       100
// Peer had an error
#define POLO_ERR_PAIRING_PEER_ERROR             101
#define POLO_ERR_PAIRING_BAD_CONFIG             102
// Peer doesn't except the secret, or something else was wrong with the secret
#define POLO_ERR_PAIRING_BAD_SECRET             103
// Received something unexpected
#define POLO_ERR_PAIRING_MISSING_REQ_ACK        110
#define POLO_ERR_PAIRING_MISSING_OPTIONS        111
#define POLO_ERR_PAIRING_MISSING_CONFIG_ACK     112
#define POLO_ERR_PAIRING_MISSING_SECRET_ACK     113
// Can't agree on encoding with the other peer
#define POLO_ERR_PAIRING_ENCODING_NEGOTIATION   120
// Can't write the peer's certificate to the local storage
#define POLO_ERR_PAIRING_CANT_WRITE_CERT        121

// ObjC errors
#define POLO_ERR_CANT_SETUP_CF_SOCKET           130

// Atomic operations
#if defined(__GNUC__)
#define POLO_ATOMIC_INCREMENT(ptr) __sync_add_and_fetch(ptr, 1)
#define POLO_ATOMIC_DECREMENT(ptr) __sync_sub_and_fetch(ptr, -1)
#define POLO_ATOMIC_COMPARE_AND_SWAP(ptr, oldVal, newVal) \
__sync_bool_compare_and_swap(ptr, oldVal, newVal)
#elif defined(__APPLE__)
#include <libkern/OSAtomic.h>
#define POLO_ATOMIC_INCREMENT(ptr) OSAtomicIncrement32Barrier(ptr)
#define POLO_ATOMIC_DECREMENT(ptr) OSAtomicDecrement32Barrier(ptr)
#define POLO_ATOMIC_COMPARE_AND_SWAP(ptr, oldVal, newVal) \
OSAtomicCompareAndSwap32Barrier(oldVal, newVal, ptr)
#else
#error Atomic operations aren't implemented for this platform
#endif

#ifdef  __cplusplus
}
#endif
#endif
