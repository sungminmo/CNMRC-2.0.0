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
#import "CommandSender.h"
#import "PoloObjC.h"


@protocol PoloSenderDelegate;

// A command sender using the Polo encrypted protocol
@interface PoloSender : CommandSender <PoloConnectionDelegate> {
 @private
  PoloConnection *poloConnection_;
  id<PoloSenderDelegate> delegate_;

  // All messages to the box are being sent through this queue. This is
  // single thread executor.
  NSOperationQueue *executorQueue_;
}

// The wrapped connection of the receiver. Will be nil when not connected.
@property(nonatomic, retain, readonly) PoloConnection *connection;
@property(nonatomic, assign) id<PoloSenderDelegate> delegate;

// Open a connection with the given host/port. This operation is non blocking.
- (void)connectToHost:(NSString *)host atPort:(NSInteger)port;
// Continue pairing with the given secret. Returns NO if the secret is not
// valid, and pairing won't continue.
- (BOOL)continuePairingWithSecret:(NSString *)secret;
// Cancels pairing and closes the connection
- (void)cancelPairing;
// Closes any existing connection.
- (void)close;
// Sends data to the box. If there is no connection, we report error to
// delegate. This operation is non blocking.
- (void)sendData:(const void *)data
            size:(NSUInteger)size
           error:(NSError **)outError;

@end

@protocol PoloSenderDelegate<NSObject>

- (void)poloSenderNeedsSecret:(PoloSender *)sender;
- (void)poloSenderDidConnect:(PoloSender *)sender;
- (void)poloSender:(PoloSender *)sender failedWithError:(NSError *)error;

@end

