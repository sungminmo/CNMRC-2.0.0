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

#import "PoloSender.h"
#import "PoloObjC.h"
#import "GTMDefines.h"
#import "DQAlertView.h"


@implementation PoloSender

@synthesize connection = poloConnection_;
@synthesize delegate = delegate_;


- (id)init {
  if ((self = [super init])) {
    executorQueue_ = [[NSOperationQueue alloc] init];
    [executorQueue_ setMaxConcurrentOperationCount:1];
  }
  return self;
}

- (void)dealloc {
  [executorQueue_ release];
  [poloConnection_ closeWithError:NULL];
  [poloConnection_ release];
  [super dealloc];
}

- (void)notifyAboutFailureInternal:(NSError *)error {
  [delegate_ poloSender:self failedWithError:error];
}

- (void)notifyAboutFailure:(NSError *)error {
  [self performSelectorOnMainThread:@selector(notifyAboutFailureInternal:)
                         withObject:error
                      waitUntilDone:NO];
}

- (void)connectOperation:(NSDictionary *)dict {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  NSString *host = [dict objectForKey:@"host"];
  NSInteger port = [[dict objectForKey:@"port"] intValue];

  NSString *name = [[UIDevice currentDevice] name];
  PoloClient *client = [PoloClient clientWithName:name];
  [client setClientName:name];
  [client setServiceName:@"IpRemote"];

  if (![client isSaved]) {
    [client saveToKeychain];
  }

  if (poloConnection_) {
    [poloConnection_ closeWithError:NULL];
    [poloConnection_ release];
  }
  poloConnection_ = [[PoloConnection alloc] init];
  [poloConnection_ setClient:client];
  [poloConnection_ setHost:host];
  [poloConnection_ setPort:(int)port];
  [poloConnection_ setPreferredRole:PoloConnectionRoleInput];
  NSArray *encodings = [NSArray arrayWithObjects:
                        [PoloConnectionEncodingEntry entryWithEncoding:PoloConnectionEncodingHexadecimal
                                                                length:4],
                        nil];
  [poloConnection_ setInputEncodings:encodings];
  [poloConnection_ setDelegate:self];
  [poloConnection_ setPairingPort:(int)port + 1];
  [poloConnection_ scheduleWithRunloop:[NSRunLoop mainRunLoop]
                                  mode:NSDefaultRunLoopMode];
    
  DDLogDebug(@"%@ - %@ - %d - %@", client, host, (int)port, encodings);
  NSError *err = nil;
  if (![poloConnection_ openWithError:&err]) {
    DDLogWarn(@"Can't open connection: %@", err);
    [poloConnection_ release];
    poloConnection_ = nil;
    [self notifyAboutFailure:err];
  }

  [pool release];
}

- (void)connectToHost:(NSString *)host atPort:(NSInteger)port {
  NSLog(@"Connect box address:%@ prot: %d", host, (int)port);
    
  NSArray *objects = [NSArray arrayWithObjects:host, [NSNumber numberWithInt:(int)port], nil];
  NSArray *keys = [NSArray arrayWithObjects:@"host", @"port", nil];
  NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
  NSOperation *op = [[[NSInvocationOperation alloc]
                        initWithTarget:self
                              selector:@selector(connectOperation:)
                                object:dict] autorelease];
  [executorQueue_ addOperation:op];
}

- (void)poloConnectionWaitingForSecret:(PoloConnection *)connection {
  [[self delegate] poloSenderNeedsSecret:self];
}

- (BOOL)continuePairingWithSecret:(NSString *)secret {
  BOOL isOK = [poloConnection_ continuePairingWithSecret:secret error:NULL];
  if (!isOK) {
      DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"코드 오류"
                                                          message:@"입력된 페어링 코드가 들렸습니다!"
                                                cancelButtonTitle:nil
                                                 otherButtonTitle:@"확인"];
      alertView.shouldDismissOnActionButtonClicked = YES;
      alertView.otherButtonAction = ^{
          DDLogDebug(@"OK Clicked");
      };
      
      [alertView show];
      [alertView release];
  }
  return isOK;
}

- (void)poloConnectionOpened:(PoloConnection *)connection {
  [[self delegate] poloSenderDidConnect:self];
}

- (void)cancelPairing {
  [poloConnection_ cancelPairing];
}

- (void)sendDataOperation:(NSData *)data {
  NSError *error;
  if (![poloConnection_ writeData:data error:&error]) {
    [self notifyAboutFailure:error];
  }
}

- (void)sendData:(const void *)data
            size:(NSUInteger)size
           error:(NSError **)outError {

  // TODO(wiktorgworek): remove outError, all errors should be reported
  //                     to delegates only

  // 접속 여부?
  if (!poloConnection_) {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Not connected", nil),
                          NSLocalizedFailureReasonErrorKey,
                          nil];
    NSError *error = [NSError errorWithDomain:PoloErrorDomain
                                         code:POLO_ERR_NOT_CONNECTED
                                     userInfo:info];
    [delegate_ poloSender:self failedWithError:error];
    return;
  }

  // Data is being copied by NSData as it is passed to other thread.
  NSData *buff = [NSData dataWithBytes:(void *)data length:size];

  NSOperation *op = [[[NSInvocationOperation alloc]
                       initWithTarget:self
                             selector:@selector(sendDataOperation:)
                               object:buff] autorelease];
  [executorQueue_ addOperation:op];
}

- (void)poloConnection:(PoloConnection *)connection
       failedWithError:(NSError *)error {
  [self notifyAboutFailure:error];
}

- (void)close {
  [poloConnection_ closeWithError:nil];
  [poloConnection_ release];
  poloConnection_ = nil;
}

@end
