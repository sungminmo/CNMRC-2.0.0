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

#import "CommandSender.h"
#include "remote.pb.h"
#include <google/protobuf/io/coded_stream.h>

using namespace std;
using namespace google::protobuf;
using namespace google::protobuf::io;
using namespace anymote::messages;

@implementation CommandSender

#pragma mark Implementation of the CommandSender protocol

- (BOOL)sendRequest:(RequestMessage *)request error:(NSError **)outError {
  RemoteMessage message;
  *message.mutable_request_message() = *request;
  size_t msgLength = message.ByteSize();
  size_t encodedLengthSize = CodedOutputStream::VarintSize32(msgLength);
  void *data = malloc(msgLength + encodedLengthSize);
  if (!data) {
    if (outError) {
      NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"malloc() returned NULL", nil),
                            NSLocalizedFailureReasonErrorKey,
                            nil];
      *outError = [NSError errorWithDomain:AnymoteErrorDomain
                                      code:kAnymoteErrorMalloc
                                  userInfo:info];
    }
    return NO;
  }
  CodedOutputStream::WriteVarint32ToArray(msgLength,
                                          (uint8 *)data);
  BOOL result = NO;
  if (!message.SerializeToArray((uint8_t *)data + encodedLengthSize,
                                msgLength)) {
    if (outError) {
      NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"Protobuf serialization of "
                                              "Anymote message failed", nil),
                            NSLocalizedFailureReasonErrorKey,
                            nil];
      *outError = [NSError errorWithDomain:AnymoteErrorDomain
                                      code:kAnymoteErrorCantSerializeMessage
                                  userInfo:info];
    }
  } else {
    [self sendData:data
              size:msgLength + encodedLengthSize
             error:outError];
    result = (!outError);
  }
  free(data);
  return result;
}

- (BOOL)sendClickWithError:(NSError **)outError {
  return [self sendClickForKey:BTN_MOUSE error:outError];
}

- (BOOL)moveRelativeDeltaX:(int)x deltaY:(int)y error:(NSError **)outError {
  RequestMessage request;
  request.mutable_mouse_event_message()->set_x_delta(x);
  request.mutable_mouse_event_message()->set_y_delta(y);
  return [self sendRequest:&request error:outError];
}

- (BOOL)enterText:(NSString *)text error:(NSError **)outError {
  RequestMessage request;
  request.mutable_data_message()->set_type("com.google.tv.string");
  request.mutable_data_message()->set_data([text UTF8String]);
  return [self sendRequest:&request error:outError];
}

- (BOOL)sendAction:(int)action forKey:(int)keyCode error:(NSError **)outError {
  RequestMessage request;
  request.mutable_key_event_message()->set_keycode((Code)keyCode);
  request.mutable_key_event_message()->set_action((Action)action);
  return [self sendRequest:&request error:outError];
}

- (BOOL)sendClickForKey:(int)keyCode error:(NSError **)outError {
  BOOL result = [self sendAction:DOWN forKey:keyCode error:outError];
  if (result)
    result = [self sendAction:UP forKey:keyCode error:outError];
  return result;
}

- (BOOL)gotoUrlString:(NSString *)urlString error:(NSError **)outError {
  RequestMessage request;
  request.mutable_fling_message()->set_uri([urlString UTF8String]);
  return [self sendRequest:&request error:outError];
}

- (BOOL)scrollDeltaX:(int)x deltaY:(int)y error:(NSError **)outError {
  RequestMessage request;
  request.mutable_mouse_wheel_message()->set_x_scroll(x);
  request.mutable_mouse_wheel_message()->set_y_scroll(y);
  return [self sendRequest:&request error:outError];
}

- (BOOL)zoomIn:(BOOL)isIn error:(NSError **)outError {
  return [self sendClickForKey:isIn ? KEYCODE_ZOOM_IN : KEYCODE_ZOOM_OUT
                         error:outError];
}

- (void)sendData:(const void *)data
            size:(NSUInteger)size
           error:(NSError **)outError {
  NSLog(@"Missing override %@", NSStringFromSelector(@selector(cmd)));
}

- (id)delegate {
  return nil;
}

- (void)setDelegate:(id)delegate {
}

- (void)close {
}

@end

NSString * const AnymoteErrorDomain = @"AnymoteErrorDomain";
