/*
  * Copyright 2012 Google Inc. All Rights Reserved.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *      http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

// This file contains the entire pairing logic. Its entry point is the
// PoloConnectionPairingThread(), which is an entry point for a thread spawned
// by PoloConnectionStartPairing(). The rest of the stuff in here are utilities
// for the pairing logic.
//
// WARNING: This code is pretty much my first attempt on both reading and
// writing C++ code. It's probably full of bad habits and doesn't look anything
// like "good" code (although it should work). Feel free to improve it though :)

//#include "PoloPairingImpl.h"
#include "polo.pb.h"
#include "PoloClient.h"
#include <arpa/inet.h>


using namespace std;
using namespace google::protobuf;
using namespace polo::wire::protobuf;

extern "C" {
    // These are a bunch of private functions reserved especially for us
    extern void PoloConnectionSetPeerName(PoloConnectionRef connection,
                                          const char *str);
    void PoloConnectionSetEncoding(PoloConnectionRef connection,
                                   PoloConnectionEncoding encoding);
    void PoloConnectionSetRole(PoloConnectionRef connection,
                               PoloConnectionRole role);
    int PoloConnectionCloseInternal(PoloConnectionRef connection);
#ifdef __APPLE__
    void PoloConnectionObjCWaitingForSecret(PoloConnectionRef connection);
    void PoloConnectionObjCPairingEnded(PoloConnectionRef connection, int status);
#endif
}

// Writes a given block of memory to the given bio.
static inline size_t PoloWriteToBIO(BIO *bio, const void *bytes, size_t len) {
    size_t totalSent = 0;
    do {
        size_t sent = BIO_write(bio, bytes, (int)len);
        
        // 0 means the connection was closed
        if (sent == 0) {
            totalSent = 0;
            break;
        }
        
        totalSent += sent;
    } while (totalSent < len);
    return totalSent;
};

// Writes the given message to |bio| in the format expected by our protocol.
static size_t PoloWriteMessageToBIO(BIO *bio, OuterMessage *message) {
    pthread_testcancel();
    
    // The format we currently use is the encoded message, prefixed by the length
    // (in bytes) of the encoded message, as a 32 bit big endian number.
    uint32_t length = message->ByteSize();
    void *data = malloc(length + sizeof(int32_t));
    size_t sentDataLen;
    
    *((uint32_t *)data) = htonl(length); // Length of the message in big endian
    message->SerializeToArray((uint8_t *)data + sizeof(uint32_t), length);
    sentDataLen = PoloWriteToBIO(bio, data, length + sizeof(uint32_t));
    free(data);
    pthread_testcancel();
    return sentDataLen;
}

// Reads the next message from the given bio, and places it in *|outMsg|.
// This function blocks until the complete message arrives. Currently, the
// protocol and the implementation assumes no data was read from the bio between
// calls of this function.
static bool PoloReadMessageFromBIO(BIO *bio, OuterMessage *outMsg) {
    int length;
    int bytesRead;
    bool result = false;
    
    pthread_testcancel();
    // First, we read the length of the encoded message.
    bytesRead = BIO_read(bio, (void *)&length, sizeof(length));
    
    if (bytesRead == sizeof(length)) {
        void *buff;
        
        pthread_testcancel();
        length = ntohl(length); // length is in big endian
        buff = malloc(length);
        bytesRead = BIO_read(bio, buff, length); // Read the actual message
        
        if (bytesRead == length) {
            if (outMsg->ParseFromArray(buff, length)) // Decode the message
                result = true;
        }
        
        free(buff);
    }
    pthread_testcancel();
    return result;
}

static Options_Encoding_EncodingType
PoloProtoOptionsEncodingTypeFromType(PoloConnectionEncodingType type) {
    return (Options_Encoding_EncodingType)type;
}

static PoloConnectionEncodingType
PoloConnectionEncodingTypeFromProtoType(Options_Encoding_EncodingType type) {
    return (PoloConnectionEncodingType)type;
}

static Options_RoleType PoloProtoRoleTypeFromRole(PoloConnectionRole role) {
    return (Options_RoleType)role;
}

// Given the client's and the server's options, this function determines the
// best encoding to use. Currently, we try to use the best option for the client
// which the server also supports.
// If a suitable encoding was found, it'll be placed in *|outEncoding|.
// Returns 1 if an encoding was found, 0 otherwise.
static int
findBestEncodingType(const RepeatedPtrField< Options_Encoding >& clientOptions,
                     const RepeatedPtrField< Options_Encoding >& serverOptions,
                     PoloConnectionEncoding *outEncoding) {
    // This is probably the stupidest way to perform the intersection but this
    // c++ stuff gives me a headache. Besides that, these arrays are expected
    // to have ~5 items each so it's pretty safe to assume this code won't take
    // too long to complete.
    // TODO(ofri): Make this code pretty
    for (int i = 0; i < clientOptions.size(); ++i) {
        Options_Encoding clientOption = clientOptions.Get(i);
        
        for (int j = 0; j < serverOptions.size(); ++j) {
            Options_Encoding serverOption = serverOptions.Get(j);
            
            if (clientOption.type() == serverOption.type() &&
                clientOption.symbol_length() == serverOption.symbol_length()) {
                PoloConnectionEncoding result = {
                    PoloConnectionEncodingTypeFromProtoType(clientOption.type()),
                    clientOption.symbol_length()
                };
                
                *outEncoding = result;
                return 1;
            }
        }
    }
    
    return 0;
}

static void PoloConnectionPairingThreadCleanup(void *connectionPtr) {
    PoloConnectionRef connection = (PoloConnectionRef)connectionPtr;
    
    if (connection->secret) {
        PoloMemoryAllocatorStrongResign(connection->secret);
        connection->secret = NULL;
        connection->secretLength = 0;
    }
    PoloConnectionCloseInternal(connection);
}

// !!!: READ_NEXT_ MSG 매크로 대체 함수.
static void ReadNextMsg()
{
    
}

// This function implements the pairing logic. It is designed as an entry point
// for a new thread, and always returns NULL. It takes a single parameter, of
// type PoloConnectionRef, which is the connection that started the thread.
extern "C" void *PoloConnectionPairingThread(void *connectionPtr) {
    PoloConnectionRef connection = (PoloConnectionRef)connectionPtr;
    BIO *bio = PoloConnectionGetBIO(connection);
    OuterMessage outgoingMsg;
    PoloClientRef client = PoloConnectionGetClient(connection);
    OuterMessage incomingMsg;
    string serializedPayload;
    struct PoloConnectionCallbacks *callbacks;
    callbacks = PoloConnectionGetCallbacks(connection);
    
    // Register cleanup function
    pthread_cleanup_push(PoloConnectionPairingThreadCleanup, connectionPtr);
    
    // Make our thread cancelable. We have cancellation points in read/write
    // message functions.
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, NULL);
    
    // Exit the thread with a given error code
#ifdef __APPLE__
#define EXIT_WITH_CODE(exitCode) {\
if (callbacks->pairingEnded) {\
pthread_testcancel();\
callbacks->pairingEnded(connection, exitCode, callbacks->info);\
}\
PoloConnectionObjCPairingEnded(connection, exitCode);\
pthread_exit(NULL);\
}
#else
#define EXIT_WITH_CODE(exitCode) {\
if (callbacks->pairingEnded) {\
pthread_testcancel();\
callbacks->pairingEnded(connection, exitCode, callbacks->info);\
}\
pthread_exit(NULL);\
}
#endif
    
    // Write the next message of the given type to the bio
#define WRITE_NEXT_MSG(type) {\
pthread_testcancel();\
outgoingMsg.set_type(type);\
outgoingMsg.set_payload(serializedPayload);\
if (PoloWriteMessageToBIO(bio, &outgoingMsg) == 0)\
EXIT_WITH_CODE(POLO_ERR_PAIRING_CONNECTION_ERROR);\
}
    

// !!! 사용하지 않음.
    
    /*
    
    // Read the next message from the bio. |wrongMsgCode| is the error code
    // that'll be reported if the message can't be read. This macro also handles
    // other types
#define READ_NEXT_MSG(wrongMsgCode) {\
pthread_testcancel();\
if (!PoloReadMessageFromBIO(bio, &incomingMsg))\
EXIT_WITH_CODE(wrongMsgCode);\
switch (incomingMsg.status() != OuterMessage_Status_STATUS_OK) {\
case OuterMessage_Status_STATUS_ERROR:\
EXIT_WITH_CODE(POLO_ERR_PAIRING_CONNECTION_ERROR);\
break;\
case OuterMessage_Status_STATUS_BAD_CONFIGURATION:\
EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_CONFIG);\
break;\
case OuterMessage_Status_STATUS_BAD_SECRET:\
EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);\
break;\
case OuterMessage_Status_STATUS_OK:\
default:\
break;\
}\
}
     */

    outgoingMsg.set_protocol_version(1);
    outgoingMsg.set_status(OuterMessage_Status_STATUS_OK);
    
    // Send the pairing request
    PairingRequest pairingRequest;
    string serviceName(PoloClientGetServiceName(client));
    string clientName(PoloClientGetClientName(client));
    
    pairingRequest.set_service_name(serviceName);
    pairingRequest.set_client_name(clientName);
    pairingRequest.SerializeToString(&serializedPayload);
    WRITE_NEXT_MSG(OuterMessage_MessageType_MESSAGE_TYPE_PAIRING_REQUEST);
    
    // Wait for a pairing request ack
    //READ_NEXT_MSG(POLO_ERR_PAIRING_MISSING_REQ_ACK);
    // 테스트 ----------------------------------------------------------------------
    pthread_testcancel();
    if (!PoloReadMessageFromBIO(bio, &incomingMsg))
        EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_REQ_ACK);
    
    if (incomingMsg.status() != OuterMessage_Status_STATUS_OK)
    {
        if (incomingMsg.status() == OuterMessage_Status_STATUS_ERROR)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_CONNECTION_ERROR);
        }
        else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_CONFIGURATION)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_CONFIG);
        }
        else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_SECRET)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);
        }
    }
    // 테스트 ----------------------------------------------------------------------
    
    PairingRequestAck pairingRequestAck;
    if (!pairingRequestAck.ParseFromString(incomingMsg.payload()))
        EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_REQ_ACK);
    
    // Check cancellation status before changing our host name
    pthread_testcancel();
    PoloConnectionSetPeerName(connection,
                              pairingRequestAck.server_name().c_str());
    
    // Build our options message
    Options clientOptions;
    PoloConnectionEncodingsSet encodings;
    PoloConnectionRole preferredRole = PoloConnectionGetPreferredRole(connection);
    
    clientOptions.set_preferred_role(PoloProtoRoleTypeFromRole(preferredRole));
    
    // input encodings
    encodings = PoloConnectionGetInputEncodings(connection);
    for (size_t i = 0; i < encodings.count; ++i) {
        PoloConnectionEncoding entry = encodings.entries[i];
        Options_Encoding *mutableEncodings = clientOptions.add_input_encodings();
        
        mutableEncodings->set_type(PoloProtoOptionsEncodingTypeFromType(entry.type));
        mutableEncodings->set_symbol_length(entry.symbolLength);
    }
    
    // output encodings
    encodings = PoloConnectionGetOutputEncodings(connection);
    for (size_t i = 0; i < encodings.count; ++i) {
        PoloConnectionEncoding entry = encodings.entries[i];
        Options_Encoding *mutableEncodings = clientOptions.add_output_encodings();
        
        mutableEncodings->set_type(PoloProtoOptionsEncodingTypeFromType(entry.type));
        mutableEncodings->set_symbol_length(entry.symbolLength);
    }
    
    // Send our options
    clientOptions.SerializeToString(&serializedPayload);
    WRITE_NEXT_MSG(OuterMessage_MessageType_MESSAGE_TYPE_OPTIONS);
    
    // Wait for the server's options
    //READ_NEXT_MSG(POLO_ERR_PAIRING_MISSING_OPTIONS);
    // 테스트 ----------------------------------------------------------------------
    pthread_testcancel();
    if (!PoloReadMessageFromBIO(bio, &incomingMsg))
        EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_OPTIONS);
    
    if (incomingMsg.status() != OuterMessage_Status_STATUS_OK)
    {
        if (incomingMsg.status() == OuterMessage_Status_STATUS_ERROR)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_CONNECTION_ERROR);
        }
        else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_CONFIGURATION)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_CONFIG);
        }
        else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_SECRET)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);
        }
    }
    // 테스트 ----------------------------------------------------------------------
    
    
    Options serverOptions;
    if (!serverOptions.ParseFromString(incomingMsg.payload()))
        EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_OPTIONS);
    
    // Find our role and encoding
    PoloConnectionEncoding selectedEncoding;
    PoloConnectionRole role = PoloConnectionGetPreferredRole(connection);
    
    if (role == PoloConnectionRoleInput) {
        if (findBestEncodingType(clientOptions.input_encodings(),
                                 serverOptions.output_encodings(),
                                 &selectedEncoding)) {
            PoloConnectionSetRole(connection, role);
            PoloConnectionSetEncoding(connection, selectedEncoding);
        } else if (findBestEncodingType(clientOptions.output_encodings(),
                                        serverOptions.input_encodings(),
                                        &selectedEncoding)) {
            PoloConnectionSetRole(connection, PoloConnectionRoleOutput);
            PoloConnectionSetEncoding(connection, selectedEncoding);
        } else {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_ENCODING_NEGOTIATION);
        }
    }
    
    // Build our config msg
    Configuration outputConfig;
    Options_Encoding_EncodingType negotiatedType;
    
    outputConfig.set_client_role(PoloProtoRoleTypeFromRole(role));
    negotiatedType = PoloProtoOptionsEncodingTypeFromType(selectedEncoding.type);
    outputConfig.mutable_encoding()->set_type(negotiatedType);
    outputConfig.mutable_encoding()->set_symbol_length(selectedEncoding.symbolLength);
    
    // Send our config
    outputConfig.SerializeToString(&serializedPayload);
    WRITE_NEXT_MSG(OuterMessage_MessageType_MESSAGE_TYPE_CONFIGURATION);
    
    // Wait for the server's options
    //READ_NEXT_MSG(POLO_ERR_PAIRING_MISSING_CONFIG_ACK);
    // 테스트 ----------------------------------------------------------------------
    pthread_testcancel();
    if (!PoloReadMessageFromBIO(bio, &incomingMsg))
        EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_CONFIG_ACK);
    
    if (incomingMsg.status() != OuterMessage_Status_STATUS_OK)
    {
        if (incomingMsg.status() == OuterMessage_Status_STATUS_ERROR)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_CONNECTION_ERROR);
        }
        else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_CONFIGURATION)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_CONFIG);
        }
        else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_SECRET)
        {
            EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);
        }
    }
    // 테스트 ----------------------------------------------------------------------
    
    ConfigurationAck configAck;
    if (!configAck.ParseFromString(incomingMsg.payload()))
        EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_CONFIG_ACK);
    
    // Set the connection's encoding to the enoding we selected
    connection->encoding = selectedEncoding;
    
    if (role == PoloConnectionRoleInput) {
        // Invoke our callback so the rest of the world know we're about to wait for
        // the secret.
        
        if (callbacks->waitingForSecret) {
            pthread_testcancel();
            connection->secret = callbacks->waitingForSecret(connection,
                                                             &connection->secretLength,
                                                             callbacks->info);
        }
        
        if (!connection->secret) {
#ifdef __APPLE__
            PoloConnectionObjCWaitingForSecret(connection);
#endif
            
            // Wait for the app to provide the secret the user entered
            pthread_mutex_lock(&connection->secretMutex);
            if (pthread_cond_wait(&connection->secretConditionLock,
                                  &connection->secretMutex)) {
                EXIT_WITH_CODE(POLO_ERR_INTERNAL);
            }
            
            pthread_testcancel();
            
            //void *secret = connection->secret;
            if (!connection->secret)
                EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);
            
            /*size_t secretLength = PoloGetSecretLengthForEncoding(selectedEncoding);
             PoloClientRef client = PoloConnectionGetClient(connection);
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
             if (memcmp(connection->secret, secretAlpha, secretLength / 2))
             EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);*/
            
            // Send the secret to the other side
            Secret secretMsg;
            //secretMsg.set_secret(secretAlpha, alphaLen);
            secretMsg.set_secret(connection->secret, connection->secretLength);
            secretMsg.SerializeToString(&serializedPayload);
            WRITE_NEXT_MSG(OuterMessage_MessageType_MESSAGE_TYPE_SECRET);
            
            // Wait for the secret ack
            //READ_NEXT_MSG(POLO_ERR_PAIRING_MISSING_SECRET_ACK);
            // 테스트 ----------------------------------------------------------------------
            pthread_testcancel();
            if (!PoloReadMessageFromBIO(bio, &incomingMsg))
                EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_SECRET_ACK);
            
            if (incomingMsg.status() != OuterMessage_Status_STATUS_OK)
            {
                if (incomingMsg.status() == OuterMessage_Status_STATUS_ERROR)
                {
                    EXIT_WITH_CODE(POLO_ERR_PAIRING_CONNECTION_ERROR);
                }
                else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_CONFIGURATION)
                {
                    EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_CONFIG);
                }
                else if (incomingMsg.status() == OuterMessage_Status_STATUS_BAD_SECRET)
                {
                    EXIT_WITH_CODE(POLO_ERR_PAIRING_BAD_SECRET);
                }
            }
            // 테스트 ----------------------------------------------------------------------
            SecretAck secretAckMsg;
            if (!secretAckMsg.ParseFromString(incomingMsg.payload()))
                EXIT_WITH_CODE(POLO_ERR_PAIRING_MISSING_SECRET_ACK);
            
            // Save the peer's certificate in our storage
            SSL *ssl;
            BIO_get_ssl(bio, &ssl);
            X509 *peerCertificate = SSL_get_peer_certificate(ssl);
            PoloCertificatesStorageRef certsStorage;
            certsStorage = PoloConnectionGetCertificatesStorage(connection);
            if (certsStorage)
                PoloCertificatesStorageAddCertificate(certsStorage, peerCertificate);
        }
    } else {
        puts("Output device role isn't implemented yet.");
        EXIT_WITH_CODE(POLO_ERR_PAIRING_ENCODING_NEGOTIATION);
    }
    pthread_cleanup_pop(1);
    EXIT_WITH_CODE(POLO_ERR_OK);
    
#undef READ_NEXT_MSG
#undef WRITE_NEXT_MSG
#undef EXIT_WITH_CODE
    return NULL;  // Keep GCC happy
}
