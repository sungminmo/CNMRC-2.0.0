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

#import <Foundation/Foundation.h>
#include <Polo/PoloClient.h>

// PoloClient provides an ObjC wrapper around the PoloClientRef C API.
// In addition to providing ObjC abstration for primitive C types it also
// provides transparent keychain integration.
// PoloClient is toll-free bridged to PoloClientRef.
//
// A polo client object encapsulates the identity of an app that wishes to pair
// with a different app/device. A single client can be shared among many
// PoloConnections.
@interface PoloClient : NSObject

// Returns a client with a given name. If a client is not already present in the
// keychain, a new client will be created. If an existing client already exists,
// it'll be returned.
+ (PoloClient *)clientWithName:(NSString *)name;

#if TARGET_OS_IPHONE
// This method does the same thing as +clientWithName:, except it allows you to
// provide a keychain access group. Access groups allow you to share clients
// between applications. Check out the Keychain Services Refernece here https://developer.apple.com/library/ios/#documentation/Security/Reference/keychainservices/Reference/reference.html
// for more info.
+ (PoloClient *)clientWithName:(NSString *)name
                   accessGroup:(NSString *)accessGroup;
#endif

// The service you wish to pair with on the other side. Each polo server
// maintains a database of services and may limit a client's access only to the
// service it paired with. A pairing service is required for a connection to be
// established.
// The value of this property is NOT saved with the client.
@property(nonatomic, copy) NSString *serviceName;
// An optional client name which will be used on the other side. This will
// probably be displayed to users.
// The value of this property is NOT saved with the client.
@property(nonatomic, copy) NSString *clientName;
// Returns the name of the receiver that is used internally.
@property(nonatomic, readonly) NSString *name;
// Returns whether the receiver is saved to keychain or not.
@property(nonatomic, readonly, getter=isSaved) BOOL saved;

// Generates a new identity for the client. Generally you'll never use this
// method.
- (void)generateIdentityWithName:(NSString *)name;

// Saves the receiver to keychain. You may check the value of the |saved|
// property before invoking this method.
// NOTE: Even if you saved your client before you may need to save it again
// on a later time. Therefore, after you get your client from
// +clientWithName:, you should always save if needed.
- (BOOL)saveToKeychain;
// Attempts to delete the receiver from the keychain. Does nothing if the
// receiver isn't saved.
- (void)deleteFromKeychain;

#if TARGET_OS_IPHONE
// Save/delete variants with access group. Check +clientWithName:accessGroup:
// for more info on access groups.
- (void)deleteFromKeychainWithAccessGroup:(NSString *)accessGroup;
- (BOOL)saveToKeychainWithAccessGroup:(NSString *)accessGroup;
#endif

@end

// A simple object wrapper around connection encoding. It's provided as a means
// for creating a more native API for PoloConnection.
@interface PoloConnectionEncodingEntry : NSObject {
  PoloConnectionEncoding encoding;
}

@property(nonatomic, readonly) PoloConnectionEncoding encoding;

+ (id)entryWithEncoding:(enum PoloConnectionEncodingType)type
                 length:(uint32_t)length;
- (id)initWithEncoding:(enum PoloConnectionEncodingType)encodingType
                length:(uint32_t)symbolLength;
@end

@protocol PoloConnectionDelegate;

// PoloConnection is an object wrapper around the PoloConnectionRef C API.
// PoloConnection implements a pairing based, secure connection. It functions
// similarly to how pairing in Bluetooth is done.
// PoloConnection is toll-free bridged to PoloConnectionRef.
@interface PoloConnection : NSObject

// Required. The identity of the connection.
@property(nonatomic, retain) PoloClient *client;
// The host to connect to. You may provide a string in the format of "host:port"
// which will automatically parse the port and set it.
@property(nonatomic, copy) NSString *host;
// The port to connect to.
@property(nonatomic) int port;
// If your host is using a non-standard pairing port, you can set it with this
// property. Otherwise, leave it at the default value.
@property(nonatomic) int pairingPort;
@property(nonatomic, assign) id <NSObject, PoloConnectionDelegate> delegate;
// Supported encodings when acting as an input node.
@property(nonatomic, copy) NSArray *inputEncodings;
// Supported encodings when acting as an output node.
@property(nonatomic, copy) NSArray *outputEncodings;
// The preferred role the connection should use if pairing is needed.
@property(nonatomic) PoloConnectionRole preferredRole;
// The actual role of the connection, as negotated with the other peer.
// The value of this property is available only while pairing. Otherwise its
// value is undefined.
@property(nonatomic, readonly) PoloConnectionRole role;
// The encoding used to pass the pairing secret, as negotated with the peer.
@property(nonatomic, readonly) PoloConnectionEncodingEntry *encoding;
// The name of the peer the connection is pairing with. This value is available
// only while pairing.
@property(nonatomic, readonly) NSString *peerName;

// You can probably guess how to use these
- (BOOL)openWithError:(NSError **)error;
- (BOOL)closeWithError:(NSError **)error;

// Continues pairing with a given secret. The passed secret may be either an
// NSString instance with the encoded secret, or an NSData with the raw secret.
// Returns YES is secret is vaild and pairing continues, NO if a bad secret was
// provided.
// This method attempts to verify the passed secret against the receiver's local
// view of the connection. If the secret appears to be wrong, this method will
// return NO. You can check the code of the returned error for the exact failure
// reason (codes are defined in PoloClient.h).
- (BOOL)continuePairingWithSecret:(id)secret error:(NSError **)outError;

// Attempts to cancel pairing. Does nothing if the receiver is not currently in
// an active pairing process.
- (void)cancelPairing;

// These methods block
- (BOOL)writeData:(NSData *)data error:(NSError **)outError;
- (NSData *)readData:(size_t)length error:(NSError **)outError;

// Schedules the receiver with the given runloop for delivering delegate
// callbacks. You must schedule the receiver with at least one runloop in order
// to receiver delegate callbacks.
- (void)scheduleWithRunloop:(NSRunLoop *)runloop mode:(NSString *)mode;
- (void)unscheduleFromRunloop:(NSRunLoop *)runloop mode:(NSString *)mode;

@end

// Delegate methods for PoloConnection
@protocol PoloConnectionDelegate

@required
// This method is invoked when the connection is waiting for the pairing secret
// in order to finish pairing. You're responsible for obtaining the secret from
// the user and invoke -[PoloConnection continuePairingWithSecret:error:].
// The connection will not continue until you provide the secret.
- (void)poloConnectionWaitingForSecret:(PoloConnection *)connection;

@optional
// This method is being invoked when the connection detemines it's not paired
// with the host. Return YES in order to start pairing, or NO to cancel the
// connection. If you don't implement this method pairing will start.
- (BOOL)poloConnectionShouldStartPairing:(PoloConnection *)connection;
// This method is invoked when the connection has been established and the
// connection is ready to send/receive data. If pairing is needed, this method
// is invoked after pairing completes successfully.
- (void)poloConnectionOpened:(PoloConnection *)connection;
// This method gets invoked when a connection attempt failed for some reason.
- (void)poloConnection:(PoloConnection *)connection
       failedWithError:(NSError *)error;

@end

extern NSString * const PoloErrorDomain;
extern NSString * const PoloCFErrorDomain; // Errors from CoreFoundation
