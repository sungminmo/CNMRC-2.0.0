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

#import "PoloObjC.h"
#import <Security/Security.h>
#include "PoloBase.h"
#include <objc/runtime.h>
#include <unistd.h>


void PoloClassSetupBridge(struct PoloClass *class, Class bridgeClass) {
  class->instanceIsa = bridgeClass;
  class->isa = object_getClass(bridgeClass);
}

NSError *PoloNSErrorWithCode(int code);
extern int PoloConnectionIsConnected(PoloConnectionRef connection);
extern int PoloConnectionIsWaitingForSecret(PoloConnectionRef connection);


@interface PoloClientPlaceholder : NSProxy
+ (id)sharedPlaceholder;
@end

@implementation PoloClientPlaceholder

static id sharedClientPlaceholder = nil;

+ (void)initialize {
  if (self == [PoloClientPlaceholder class])
    sharedClientPlaceholder = [self alloc];
}

+ (id)sharedPlaceholder {
  return sharedClientPlaceholder;
}

- (id)init {
  return (id)PoloClientCreate(NULL);
}

@end

@implementation PoloClient

@dynamic serviceName;
@dynamic clientName;
@dynamic name;

#pragma mark Toll Free Bridge

+ (void)load {
  PoloClassSetupBridge(PoloClassGetClientClass(), self);
}

+ (id)allocWithZone:(NSZone *)zone {
  return [PoloClientPlaceholder sharedPlaceholder];
}

+ (id)alloc {
  return [PoloClientPlaceholder sharedPlaceholder];
}

- (id)retain {
  return (id)PoloRetain(self);
}

- (void)release {
  PoloRelease(self);
}

- (NSUInteger)retainCount {
  return PoloMemoryAllocatorGetRefCount(self);
}

#pragma mark Accessors

- (NSString *)serviceName {
  const char *name = PoloClientGetServiceName((PoloClientRef)self);
  return name ? [NSString stringWithUTF8String:name] : nil;
}

- (void)setServiceName:(NSString *)name {
  PoloClientSetServiceName((PoloClientRef)self, [name UTF8String]);
}

- (NSString *)clientName {
  const char *name = PoloClientGetClientName((PoloClientRef)self);
  return name ? [NSString stringWithUTF8String:name] : nil;
}

- (void)setClientName:(NSString *)name {
  PoloClientSetClientName((PoloClientRef)self, [name UTF8String]);
}

- (void)generateIdentityWithName:(NSString *)name {
  NSAssert(name != nil && [name length] > 0,
           @"Can't generate identity without a name");
  PoloClientGenerateIdentity((PoloClientRef)self,
                             [name UTF8String]);
}

#pragma mark Keychain Support

extern int PoloClientGeneratedID(PoloClientRef client);
void PoloClientSetGeneratedIDFlag(PoloClientRef client, int flag);
extern const char *PoloBase64StringFromString(const char *str);

- (NSString *)name {
  X509 *cert = PoloClientGetCertificate((PoloClientRef)self);
  X509_NAME *name = X509_get_subject_name(cert);
  int index = X509_NAME_get_index_by_NID(name,
                                         NID_commonName,
                                         -1);
  X509_NAME_ENTRY *entry = X509_NAME_get_entry(name, index);

  if (entry) {
    unsigned char *str = ASN1_STRING_data(X509_NAME_ENTRY_get_data(entry));
    return [NSString stringWithUTF8String:(const char *)str];
  } else {
    return nil;
  }
}

- (BOOL)isSaved {
  return PoloClientGeneratedID((PoloClientRef)self) == 0;
}

+ (NSData *)applicationTagWithName:(NSString *)name type:(NSString *)type {
  NSString *tag = [[NSString alloc] initWithFormat:@"%@_%@", name, type];
  const char *base64Name = PoloBase64StringFromString([tag UTF8String]);
  size_t base64NameLen = (strlen(base64Name) + 1) * sizeof(char);
  NSData *encodedName = [NSData dataWithBytesNoCopy:(void *)base64Name
                                             length:base64NameLen
                                       freeWhenDone:YES];
  [tag release];
  return encodedName;
}

+ (NSMutableDictionary *)keychainQueryForCertificateWithName:(NSString *)name
                                                 accessGroup:(NSString *)accessGroup {
  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  [query setObject:(id)kSecClassCertificate
            forKey:(id)kSecClass];
  [query setObject:(id)kSecMatchLimitOne
            forKey:(id)kSecMatchLimit];
  [query setObject:name // Name is the name of our subject
            forKey:(id)kSecMatchSubjectContains];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
  if (accessGroup)
    [query setObject:accessGroup
              forKey:(id)kSecAttrAccessGroup];
#endif
  return query;
}

+ (NSMutableDictionary *)keychainQueryForPrivateKeyWithName:(NSString *)name
                                                accessGroup:(NSString *)accessGroup {
  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  [query setObject:(id)kSecClassKey
            forKey:(id)kSecClass];
  [query setObject:(id)kSecMatchLimitOne
            forKey:(id)kSecMatchLimit];
  [query setObject:[self applicationTagWithName:name type:@"key"]
            forKey:(id)kSecAttrApplicationTag];
  [query setObject:(id)kSecAttrKeyClassPrivate
            forKey:(id)kSecAttrKeyClass];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
  if (accessGroup)
    [query setObject:accessGroup
              forKey:(id)kSecAttrAccessGroup];
#endif
  return query;
}

- (BOOL)saveCertificateWithName:(NSString *)name
                    accessGroup:(NSString *)accessGroup {
  NSMutableDictionary *query;
  CFDictionaryRef queryResult;
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

  // Create a SecCertificateRef of our client's certificate
  X509 *cert = PoloClientGetCertificate((PoloClientRef)self);
  size_t derLength = i2d_X509(cert, NULL);
  void *derData = malloc(derLength);
  i2d_X509(cert, (unsigned char **)&derData);
  derData -= derLength; // i2d_X509() incremented our pointer
  NSData *data = [NSData dataWithBytesNoCopy:derData
                                      length:derLength
                                freeWhenDone:YES];

  // Build our attributes dict
  [attributes setObject:(id)kSecClassCertificate
                 forKey:(id)kSecClass];
  [attributes setObject:(id)data
                 forKey:(id)kSecValueData];
    
#if TARGET_OS_IPHONE
  NSString *versionString = [[UIDevice currentDevice] systemVersion];
  if ([[versionString substringToIndex:1] intValue] >= 4)
    [attributes setObject:(id)kSecAttrAccessibleWhenUnlocked
                   forKey:(id)kSecAttrAccessible];
#if !TARGET_IPHONE_SIMULATOR
  if (accessGroup)
    [attributes setObject:accessGroup
                   forKey:(id)kSecAttrAccessGroup];
#endif // !TARGET_IPHONE_SIMULATOR
#endif // TARGET_OS_IPHONE

  // Build a query for our certificate
  query = [[self class] keychainQueryForCertificateWithName:name
                                                accessGroup:accessGroup];
  [query setObject:(id)kCFBooleanTrue
            forKey:(id)kSecReturnAttributes];

  OSStatus err = SecItemCopyMatching((CFDictionaryRef)query,
                                     (CFTypeRef *)&queryResult);
  // Check if our cert already exists in the keychain
  if (err != errSecSuccess) {
    err = SecItemAdd((CFDictionaryRef)attributes, NULL);
  } else {
    err = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
  }
  return err == errSecSuccess;
}

- (BOOL)savePrivateKeyWithName:(NSString *)name
                   accessGroup:(NSString *)accessGroup {
  NSMutableDictionary *query;
  NSData *encodedKeyData;
  CFDictionaryRef queryResult;
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  NSData *tag = [[self class] applicationTagWithName:name type:@"key"];

  // Encode our key
  EVP_PKEY *key = PoloClientGetPrivateKey((PoloClientRef)self);
  RSA *rsa = EVP_PKEY_get1_RSA(key);
  size_t derLength = i2d_RSAPrivateKey(rsa, NULL);
  void *derData = malloc(derLength);
  i2d_RSAPrivateKey(rsa, (unsigned char **)&derData);
  derData -= derLength; // i2d_RSAPrivateKey() incremented our pointer
  encodedKeyData = [NSData dataWithBytesNoCopy:derData
                                        length:derLength
                                  freeWhenDone:YES];

  // Build our attributes dict
  [attributes setObject:(id)kSecClassKey
                 forKey:(id)kSecClass];
  [attributes setObject:encodedKeyData
                 forKey:(id)kSecValueData];
  [attributes setObject:tag
                 forKey:(id)kSecAttrApplicationTag];
  [attributes setObject:(id)kSecAttrKeyClassPrivate
                 forKey:(id)kSecAttrKeyClass];
    
#if TARGET_OS_IPHONE
  NSString *versionString = [[UIDevice currentDevice] systemVersion];
  if ([[versionString substringToIndex:1] intValue] >= 4)
    [attributes setObject:(id)kSecAttrAccessibleWhenUnlocked
                   forKey:(id)kSecAttrAccessible];
#if !TARGET_IPHONE_SIMULATOR
  if (accessGroup)
    [attributes setObject:accessGroup
                   forKey:(id)kSecAttrAccessGroup];
#endif // !TARGET_IPHONE_SIMULATOR
#endif // TARGET_OS_IPHONE

  // Build a query for our key
  query = [[self class] keychainQueryForPrivateKeyWithName:name
                                               accessGroup:accessGroup];
  [query setObject:(id)kCFBooleanTrue
            forKey:(id)kSecReturnAttributes];
  OSStatus err = SecItemCopyMatching((CFDictionaryRef)query,
                                     (CFTypeRef *)&queryResult);

  // Check if our key already exists in the keychain
  if (err != errSecSuccess) {
    err = SecItemAdd((CFDictionaryRef)attributes, NULL);
  } else {
    err = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
  }

  return err == errSecSuccess;
}

- (BOOL)saveToKeychainWithAccessGroup:(NSString *)accessGroup {
  NSString *name = [self name];

  if ([self saveCertificateWithName:name accessGroup:accessGroup]) {
    if ([self savePrivateKeyWithName:name accessGroup:accessGroup]) {
      PoloClientSetGeneratedIDFlag((PoloClientRef)self, 0);
      return YES;
    }
  }
  return NO;
}

- (BOOL)saveToKeychain {
  return [self saveToKeychainWithAccessGroup:nil];
}

+ (PoloClient *)clientWithName:(NSString *)name
                   accessGroup:(NSString *)accessGroup {
  NSMutableDictionary *query;
  NSData *returnedData;
  PoloClientRef client = PoloClientCreate(NULL);

  [(id)client autorelease];

  // Build a query for our key
  query = [self keychainQueryForPrivateKeyWithName:name
                                       accessGroup:accessGroup];
  [query setObject:(id)kCFBooleanTrue
            forKey:(id)kSecReturnData];

    NSLog(@"SecItemCopyMatching result: %@", @(SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&returnedData)));
    NSLog(@">>>>>>>>>>>>>>>>>%@", query);
    
  if ((OSStatus)SecItemCopyMatching((CFDictionaryRef)query,
                          (CFTypeRef *)&returnedData) == errSecSuccess) {
    RSA *rsa = RSA_new();
    const unsigned char *bytes = (const unsigned char *)[returnedData bytes];
    rsa = d2i_RSAPrivateKey(&rsa,
                            &bytes,
                            [returnedData length]);

    if (rsa) {
      EVP_PKEY *key = EVP_PKEY_new();
      EVP_PKEY_set1_RSA(key, rsa);
      PoloClientSetPrivateKey(client, key);
    } else {
      PoloClientGenerateIdentity(client, [name UTF8String]);
      return (id)client;
    }
  } else {
    PoloClientGenerateIdentity(client, [name UTF8String]);
    return (id)client;
  }

  // Build a query for our certificate
  query = [self keychainQueryForCertificateWithName:name
                                        accessGroup:accessGroup];
  [query setObject:(id)kCFBooleanTrue
            forKey:(id)kSecReturnData];

  if (SecItemCopyMatching((CFDictionaryRef)query,
                          (CFTypeRef *)&returnedData) == errSecSuccess) {
    X509 *cert = X509_new();
    const unsigned char *bytes = (const unsigned char *)[returnedData bytes];
    cert = d2i_X509(&cert,
                    &bytes,
                    [returnedData length]);
    if (cert) {
      PoloClientSetCertificate(client, cert);
      // If our certificate has expired, we delete it from the keychain and
      // generate a new one.
      if (X509_cmp_current_time(X509_get_notAfter(cert)) < 0) {
        [(PoloClient *)client deleteFromKeychainWithAccessGroup:accessGroup];
        PoloClientGenerateIdentity(client, [name UTF8String]);
      }
      return (id)client;
    }
  }

  PoloClientGenerateIdentity(client, [name UTF8String]);
  return (id)client;
}

+ (PoloClient *)clientWithName:(NSString *)name {
  return [self clientWithName:name accessGroup:nil];
}

- (void)deleteFromKeychainWithAccessGroup:(NSString *)accessGroup {
  NSString *name = [self name];
  NSMutableDictionary *query;
  BOOL success;

  query = [[self class] keychainQueryForCertificateWithName:name
                                                accessGroup:accessGroup];
  success = SecItemDelete((CFDictionaryRef)query) == errSecSuccess;
  query = [[self class] keychainQueryForPrivateKeyWithName:name
                                               accessGroup:accessGroup];
  success = success && (SecItemDelete((CFDictionaryRef)query) == errSecSuccess);
  PoloClientSetGeneratedIDFlag((PoloClientRef)self, success ? 0 : 1);
}

- (void)deleteFromKeychain {
  [self deleteFromKeychainWithAccessGroup:nil];
}

@end

@implementation PoloConnectionEncodingEntry

@synthesize encoding;

+ (id)entryWithEncoding:(enum PoloConnectionEncodingType)type
                 length:(uint32_t)length {
  return [[[self alloc] initWithEncoding:type length:length] autorelease];
}

- (id)initWithEncoding:(enum PoloConnectionEncodingType)encodingType
                length:(uint32_t)symbolLength {
  if ((self = [super init])) {
    encoding.type = encodingType;
    encoding.symbolLength = symbolLength;
  }
  return self;
}

@end

@interface PoloConnectionPlaceholder : NSProxy
+ (id)sharedPlaceholder;
@end

@implementation PoloConnectionPlaceholder

static id sharedConnectionPlaceholder = nil;

+ (void)initialize {
  if (self == [PoloConnectionPlaceholder class])
    sharedConnectionPlaceholder = [self alloc];
}

- (id)init {
  PoloConnection *connection = (id)PoloConnectionCreate(NULL);
  return [connection init];
}

+ (id)sharedPlaceholder {
  return sharedConnectionPlaceholder;
}

@end


@implementation PoloConnection

@dynamic client;
@dynamic host;
@dynamic port;
@dynamic pairingPort;
@dynamic delegate;
@dynamic inputEncodings;
@dynamic outputEncodings;
@dynamic preferredRole;
@dynamic role;
@dynamic encoding;
@dynamic peerName;

#pragma mark ObjC bridge

+ (void)load {
  PoloClassSetupBridge(PoloClassGetConnectionClass(),
                       self);
  PoloInit();
}

typedef struct {
  id delegate;
  NSLock *pendingInvocationsLock;
  __strong NSMutableArray *pendingInvocations;
  //NSMutableArray *pendingInvocations;
  CFRunLoopSourceRef runloopSource;
} PoloConnectionObjCBridgeInfo;

void PoloObjCConnectionRLSourcePerformFunc(void *info) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  PoloConnectionRef connection = (PoloConnectionRef)info;
  PoloConnectionObjCBridgeInfo *bridgeInfo;
  bridgeInfo = (PoloConnectionObjCBridgeInfo *)connection->objcInfo;
  NSMutableArray *pendingInvocations = bridgeInfo->pendingInvocations;
  NSUInteger count = 0;
  NSInvocation *invocation;

  [bridgeInfo->pendingInvocationsLock lock];
  if ([pendingInvocations count] > 0) {
    NSUInteger idx = [pendingInvocations count] - 1;
    invocation = [[pendingInvocations objectAtIndex:idx] retain];
    [pendingInvocations removeObjectAtIndex:idx];
    count = idx;
  } else {
    invocation = nil;
  }
  [bridgeInfo->pendingInvocationsLock unlock];

  if (invocation) {
    [invocation invoke];
    [invocation release];
    if (count > 0)
      CFRunLoopSourceSignal(bridgeInfo->runloopSource);
  }
  [pool release];
}

- (void)scheduleInvocation:(NSInvocation *)invocation {
  PoloConnectionObjCBridgeInfo *info = ((PoloConnectionRef)self)->objcInfo;
  [info->pendingInvocationsLock lock];
  [info->pendingInvocations addObject:invocation];
  [info->pendingInvocationsLock unlock];
  CFRunLoopSourceSignal(info->runloopSource);
  CFRunLoopWakeUp(CFRunLoopGetMain());
}

// Schedules a delegate callback with the given selector.
// If the delegate doesn't respond to |selector|, no message will be scheduled.
// The message is expected to have a single argument, which is the connection
// itself.
void
PoloConnectionScheduleDelegateCallbackWithSelfArg(PoloConnectionRef connection,
                                                  SEL selector) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  id delegate = [(PoloConnection *)connection delegate];
  if ([delegate respondsToSelector:selector]) {
    NSMethodSignature *signature = [delegate methodSignatureForSelector:selector];
    NSInvocation *invocation;
    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:delegate];
    [invocation setSelector:selector];
    [invocation setArgument:&connection atIndex:2];
    [(PoloConnection *)connection scheduleInvocation:invocation];
  }
  [pool release];
}

void PoloObjCConnectionInit(PoloConnectionRef connection) {
  CFRunLoopSourceContext sourceContext = {
    0,
    connection,
    NULL, // Retain
    NULL, // Release
    NULL, // Copy Description
    NULL, // Equal
    NULL, // Hash
    NULL, // Schedule func
    NULL, // Cancel func
    PoloObjCConnectionRLSourcePerformFunc
  };
  PoloConnectionObjCBridgeInfo *info = (PoloConnectionObjCBridgeInfo *)malloc(sizeof(PoloConnectionObjCBridgeInfo));//malloc(sizeof(info));
  info->delegate = nil;
  info->pendingInvocationsLock = [[NSLock alloc] init];
  info->pendingInvocations = [[NSMutableArray alloc] init];
  info->runloopSource = CFRunLoopSourceCreate(NULL, 0, &sourceContext);
  connection->objcInfo = info;
}

void PoloObjCConnectionDestroy(PoloConnectionRef connection) {
  PoloConnectionObjCBridgeInfo *info = connection->objcInfo;
  CFRunLoopSourceInvalidate(info->runloopSource);
  CFRelease(info->runloopSource);
  [info->pendingInvocationsLock lock];
  [info->pendingInvocations release];
  info->pendingInvocations = nil;
  [info->pendingInvocationsLock unlock];
  [info->pendingInvocationsLock release];
  info->pendingInvocationsLock = nil;
  free(connection->objcInfo);
  connection->objcInfo = NULL;
}

void PoloObjCConnectionClose(PoloConnectionRef connection) {
}

void PoloObjCConnectionDidOpen(PoloConnectionRef connection) {
  SEL sel = @selector(poloConnectionOpened:);
  PoloConnectionScheduleDelegateCallbackWithSelfArg(connection, sel);
}

+ (id)allocWithZone:(NSZone *)zone {
  return [PoloConnectionPlaceholder sharedPlaceholder];
}

+ (id)alloc {
  return [PoloConnectionPlaceholder sharedPlaceholder];
}

- (id)init {
  PoloCertificatesStorageRef storage;
  PoloMemoryAllocatorRef allocator = PoloMemoryAllocatorGetAllocatorForPtr(self);
  NSString *storageDir;
  NSString *processName = [[NSProcessInfo processInfo] processName];
  storageDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                    NSUserDomainMask,
                                                    YES) objectAtIndex:0];
    
  storageDir = [storageDir stringByAppendingPathComponent:processName];
  storageDir = [storageDir stringByAppendingPathComponent:@"PoloCertificates"];

  if (![[NSFileManager defaultManager] fileExistsAtPath:storageDir]) {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithUnsignedLong:0700],
                                NSFilePosixPermissions,
                                nil];
    NSError *err;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:storageDir
                                   withIntermediateDirectories:YES
                                                    attributes:attributes
                                                         error:&err]) {
      [self release];
      return nil;
    }
  }

  storage = PoloCertificatesStorageCreateDiskStorage(allocator,
                                                     [storageDir UTF8String],
                                                     NULL);
  if (!storage) {
    [self release];
    return nil;
  } else {
    PoloConnectionSetCertificatesStorage((PoloConnectionRef)self,
                                         storage);
    PoloRelease(storage);
    return self;
  }
}

- (id)retain {
  return (id)PoloRetain(self);
}

- (void)release {
  PoloRelease(self);
}

- (NSUInteger)retainCount {
  return PoloMemoryAllocatorGetRefCount(self);
}

#pragma mark Properties

- (PoloClient *)client {
  return (PoloClient *)PoloConnectionGetClient((PoloConnectionRef)self);
}

- (void)setClient:(PoloClient *)client {
  PoloConnectionSetClient((PoloConnectionRef)self,
                          (PoloClientRef)client);
}

- (NSString *)host {
  const char *host = PoloConnectionGetHost((PoloConnectionRef)self);
  return host ? [NSString stringWithUTF8String:host] : nil;
}

- (void)setHost:(NSString *)host {
  if (host) {
    NSUInteger idx = [host rangeOfString:@":"].location;
    if (idx != NSNotFound) {
      [self setPort:[[host substringFromIndex:idx + 1] intValue]];
      host = [host substringToIndex:idx];
    }
  }
  PoloConnectionSetHost((PoloConnectionRef)self, [host UTF8String]);
}

- (int)port {
  return PoloConnectionGetPort((PoloConnectionRef)self);
}

- (void)setPort:(int)port {
  PoloConnectionSetPort((PoloConnectionRef)self, port);
}

- (int)pairingPort {
  return PoloConnectionGetPairingPort((PoloConnectionRef)self);
}

- (void)setPairingPort:(int)port {
  PoloConnectionSetPairingPort((PoloConnectionRef)self, port);
}

- (id <NSObject, PoloConnectionDelegate>)delegate {
  PoloConnectionObjCBridgeInfo *info;
  info = (PoloConnectionObjCBridgeInfo *)((PoloConnectionRef)self)->objcInfo;
  return info->delegate;
}

- (void)setDelegate:(id <NSObject, PoloConnectionDelegate>)delegate {
  PoloConnectionObjCBridgeInfo *info;
  info = (PoloConnectionObjCBridgeInfo *)((PoloConnectionRef)self)->objcInfo;
  info->delegate = delegate;
}

- (NSArray *)
encodingsWithFunction:(PoloConnectionEncodingsSet (*)(PoloConnectionRef))func {
  PoloConnectionRef connection = (PoloConnectionRef)self;
  PoloConnectionEncodingsSet set = func(connection);
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:set.count];
  size_t idx;

  for (idx = 0; idx < set.count; ++idx) {
    PoloConnectionEncoding encoding = set.entries[idx];
    PoloConnectionEncodingEntry *entry;
    entry = [[PoloConnectionEncodingEntry alloc] initWithEncoding:encoding.type
                                                           length:encoding.symbolLength];
    [result addObject:entry];
    [entry release];
  }
  return result;
}

- (void)setEncodings:(NSArray *)encodingsArr
            withFunc:(void (*)(PoloConnectionRef, PoloConnectionEncodingsSet))func {
  PoloConnectionEncodingsSet set;
  set.count = [encodingsArr count];

  if (set.count) {
    size_t idx = 0;

    set.entries = malloc(sizeof(PoloConnectionEncoding) * set.count);
    for (PoloConnectionEncodingEntry *entry in encodingsArr) {
      set.entries[idx] = [entry encoding];
      ++idx;
    }
  }

  func((PoloConnectionRef)self, set);
  if (set.entries)
    free(set.entries);
}

- (NSArray *)inputEncodings {
  return [self encodingsWithFunction:PoloConnectionGetInputEncodings];
}

- (void)setInputEncodings:(NSArray *)encodingsArr {
  [self setEncodings:encodingsArr
            withFunc:PoloConnectionSetInputEncodings];
}

- (NSArray *)outputEncodings {
  return [self encodingsWithFunction:PoloConnectionGetOutputEncodings];
}

- (void)setOutputEncodings:(NSArray *)encodingsArr {
  [self setEncodings:encodingsArr
            withFunc:PoloConnectionSetOutputEncodings];
}

- (PoloConnectionRole)preferredRole {
  return PoloConnectionGetPreferredRole((PoloConnectionRef)self);
}

- (void)setPreferredRole:(PoloConnectionRole)role {
  PoloConnectionSetPreferredRole((PoloConnectionRef)self, role);
}

- (PoloConnectionRole)role {
  return PoloConnectionGetRole((PoloConnectionRef)self);
}

- (PoloConnectionEncodingEntry *)entry {
  if (PoloConnectionIsWaitingForSecret((PoloConnectionRef)self)) {
    PoloConnectionEncoding encoding;
    encoding = PoloConnectionGetEncoding((PoloConnectionRef)self);
    return [PoloConnectionEncodingEntry entryWithEncoding:encoding.type
                                                   length:encoding.symbolLength];
  } else {
    return nil;
  }
}

- (NSString *)peerName {
  const char *name = PoloConnectionCopyPeerName((PoloConnectionRef)self);
  if (name) {
    size_t length = (strlen(name) + 1) * sizeof(char);
    NSString *result = [[NSString alloc] initWithBytesNoCopy:(void *)name
                                                      length:length
                                                    encoding:NSUTF8StringEncoding
                                                freeWhenDone:YES];

    return result;
  } else {
    return nil;
  }
}

#pragma mark Operations

- (BOOL)openWithError:(NSError **)error {
  PoloConnectionRef connection = (PoloConnectionRef)self;
  int err = PoloConnectionOpen(connection);

  if (err == POLO_ERR_NOT_PAIRED) {
    id <NSObject, PoloConnectionDelegate> delegate = [self delegate];
    if (!delegate ||
        ![delegate respondsToSelector:@selector(poloConnectionShouldStartPairing:)] ||
        [delegate poloConnectionShouldStartPairing:self]) {
      err = PoloConnectionStartPairing(connection);
    }
  }

  BOOL isOK = (err == POLO_ERR_OK);
  if (!isOK && error) {
    *error = PoloNSErrorWithCode(err);
  }
  return isOK;
}

- (BOOL)closeWithError:(NSError **)error {
  int err = PoloConnectionClose((PoloConnectionRef)self);

  if (err != POLO_ERR_OK && error)
    *error = PoloNSErrorWithCode(err);

  return err == POLO_ERR_OK;
}

- (BOOL)continuePairingWithSecret:(id)secret error:(NSError **)outError {
  int err;

  if ([secret isKindOfClass:[NSString class]]) {
    err = PoloConnectionContinuePairingWithStringSecret((PoloConnectionRef)self,
                                                        [secret UTF8String]);
  } else if ([secret isKindOfClass:[NSData class]]) {
    err = PoloConnectionContinuePairingWithSecret((PoloConnectionRef)self,
                                                  [secret length],
                                                  [secret bytes]);
  } else {
    err = POLO_ERR_BAD_ARGUMENT;
  }

  if (err == POLO_ERR_OK) {
    return YES;
  } else {
    if (outError)
      *outError = PoloNSErrorWithCode(err);
    return NO;
  }
}

- (void)cancelPairing {
  PoloConnectionCancelPairing((PoloConnectionRef)self);
}

void PoloConnectionObjCWaitingForSecret(PoloConnectionRef connection) {
  SEL sel = @selector(poloConnectionWaitingForSecret:);
  PoloConnectionScheduleDelegateCallbackWithSelfArg(connection, sel);
}

- (void)reportConnectionError:(NSError *)error {
  SEL selector = @selector(poloConnection:failedWithError:);
  if ([[self delegate] respondsToSelector:selector])
    [[self delegate] poloConnection:self failedWithError:error];
  [error release];
}

void PoloConnectionObjCPairingEnded(PoloConnectionRef connection, int status) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // After successful pairing we try to connect to the box. Because service
  // on the box is actually restarting, we might not be able to connect
  // immediately. Trying 3 times with 1s delay between retries.
  if (status == POLO_ERR_OK) {
    int retry = 3;
    while (retry > 0) {
      status = PoloConnectionOpen(connection);
      if (status == POLO_ERR_OK) {
        break;
      } else {
        retry--;
        sleep(1);
      }
    }
  }

  if (status != POLO_ERR_OK) {
    SEL selector = @selector(poloConnection:failedWithError:);
    id delegate = [(PoloConnection *)connection delegate];
    if ([delegate respondsToSelector:selector]) {
      // In order to avoid a retain loop we schedule a message to ourselves
      // and retain the error object. -reportConnectionError: will release it
      // after delivering the message. If we scheduled
      // poloConnection:failedWithError: directly to our delegate we'd have to
      // ask the invocation to retain its arguments, which will retain the
      // connection. If, in turn, the invocation can't be delivered, our
      // connection will never be freed.
      NSError *err = [PoloNSErrorWithCode(status) retain];
      NSMethodSignature *signature;
      signature = [delegate methodSignatureForSelector:selector];
      NSInvocation *invocation;
      invocation = [NSInvocation invocationWithMethodSignature:signature];
      [invocation setTarget:(id)connection];
      [invocation setSelector:@selector(reportConnectionError:)];
      [invocation setArgument:&err atIndex:2];
      [(PoloConnection *)connection scheduleInvocation:invocation];
    }
  }

  [pool release];
}

- (void)scheduleWithRunloop:(NSRunLoop *)runloop mode:(NSString *)mode {
  PoloConnectionObjCBridgeInfo *info = ((PoloConnectionRef)self)->objcInfo;
  CFRunLoopAddSource([runloop getCFRunLoop],
                     info->runloopSource,
                     (CFStringRef)mode);
}

- (void)unscheduleFromRunloop:(NSRunLoop *)runloop mode:(NSString *)mode {
  PoloConnectionObjCBridgeInfo *info = ((PoloConnectionRef)self)->objcInfo;
  CFRunLoopRemoveSource([runloop getCFRunLoop],
                        info->runloopSource,
                        (CFStringRef)mode);
}

- (BOOL)writeData:(NSData *)data error:(NSError **)outError {
  int err = PoloConnectionWrite((PoloConnectionRef)self,
                                [data bytes],
                                [data length]);

  if (err == POLO_ERR_OK) {
    return YES;
  } else {
    if (outError)
      *outError = PoloNSErrorWithCode(err);
    return NO;
  }
}

- (NSData *)readData:(size_t)length error:(NSError **)outError {
  NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
  int err = PoloConnectionRead((PoloConnectionRef)self,
                               [data mutableBytes],
                               length);

  if (err == POLO_ERR_OK) {
    return [data autorelease];
  } else {
    [data release];
    if (outError)
      *outError = PoloNSErrorWithCode(err);
    return nil;
  }
}

@end

NSString *PoloLocalizedErrorDescriptionForCode(int code) {
  switch (code) {
    case POLO_ERR_GENERIC:
      return NSLocalizedString(@"Generic pairing error had occured.", nil);

    case POLO_ERR_INTERNAL:
      return NSLocalizedString(@"Internal error had occured.", nil);

    case POLO_ERR_CONNECTION_GENERIC:
      return NSLocalizedString(@"Network error had occured.", nil);

    case POLO_ERR_NOT_CONNECTED:
      return NSLocalizedString(@"Lost connection with peer.", nil);

    case POLO_ERR_BAD_ARGUMENT:
      return NSLocalizedString(@"Bad argument was provided.", nil);

    case POLO_ERR_SECRET_UNSUPPORTED_ENCODING:
      return NSLocalizedString(@"The given encoding scheme is not currently "
                               "supported.", nil);

    case POLO_ERR_SECRET_UNKNOWN_ENCODING:
      return NSLocalizedString(@"Unknown encoding", nil);

    case POLO_ERR_SECRET_WRONG_SECRET_LENGTH:
      return NSLocalizedString(@"Wrong secret length", nil);

    case POLO_ERR_CONNECTION_FAILURE:
      return NSLocalizedString(@"Connection failure", nil);

    case POLO_ERR_NOT_PAIRED:
      return NSLocalizedString(@"Not paired with the given host.", nil);

    case POLO_ERR_MISSING_HOST:
      return NSLocalizedString(@"NULL host given", nil);

    case POLO_ERR_INVALID_CLIENT:
      return NSLocalizedString(@"The connection has an invalid client.", nil);

    case POLO_ERR_CLIENT_MISSING_CERTIFICATE:
      return NSLocalizedString(@"The client is missing a certificate.", nil);

    case POLO_ERR_CLIENT_MISSING_PRIVATE_KEY:
      return NSLocalizedString(@"The client is missing a private key.", nil);

    case POLO_ERR_CLIENT_MISSING_SERVICE_NAME:
      return NSLocalizedString(@"The client is missing a service name.", nil);

    case POLO_ERR_PAIRING_CONNECTION_ERROR:
      return NSLocalizedString(@"Connection error while pairing.", nil);

    case POLO_ERR_PAIRING_PEER_ERROR:
      return NSLocalizedString(@"The other side had an error while pairing.",
                               nil);

    case POLO_ERR_PAIRING_BAD_CONFIG:
      return NSLocalizedString(@"Peer indicated bad configuration.", nil);

    case POLO_ERR_PAIRING_BAD_SECRET:
      return NSLocalizedString(@"Peer indicated bad secret.", nil);

    case POLO_ERR_PAIRING_MISSING_REQ_ACK:
      return NSLocalizedString(@"Expected pairing request ack from peer but got"
                               " something else.", nil);

    case POLO_ERR_PAIRING_MISSING_OPTIONS:
      return NSLocalizedString(@"Expected options message from peer but got "
                               "something else.", nil);

    case POLO_ERR_PAIRING_MISSING_CONFIG_ACK:
      return NSLocalizedString(@"Expected config ack from peer but got "
                               "something else.", nil);

    case POLO_ERR_PAIRING_MISSING_SECRET_ACK:
      return NSLocalizedString(@"Expected secret ack from peer but got "
                               "something else.", nil);

    case POLO_ERR_PAIRING_ENCODING_NEGOTIATION:
      return NSLocalizedString(@"Can't negotiate an encoding eith peer.", nil);

    default:
      return nil;
  }
}

NSError *PoloNSErrorWithCode(int code) {
  return [NSError errorWithDomain:PoloErrorDomain
                             code:code
                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                   PoloLocalizedErrorDescriptionForCode(code),
                                   NSLocalizedFailureReasonErrorKey,
                                   nil]];
}

NSString * const PoloErrorDomain = @"PoloErrorDomain";
NSString * const PoloCFErrorDomain = @"PoloCFErrorDomain";
