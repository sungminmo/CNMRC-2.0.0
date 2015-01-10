/*
�* Copyright 2012 Google Inc. All Rights Reserved.
�*
�* Licensed under the Apache License, Version 2.0 (the "License");
�* you may not use this file except in compliance with the License.
�* You may obtain a copy of the License at
�*
�* � � �http://www.apache.org/licenses/LICENSE-2.0
�*
�* Unless required by applicable law or agreed to in writing, software
�* distributed under the License is distributed on an "AS IS" BASIS,
�* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
�* See the License for the specific language governing permissions and
�* limitations under the License.
�*/

// Defines an interface for sending control commands to a box.
// Translates commands into a data packet in out protcol.
// Expects subclasses to implement -[sendData:size:] to actually send the data.
@interface CommandSender : NSObject

@property (nonatomic, assign) id delegate;

// Issues a pointer click.
- (BOOL)sendClickWithError:(NSError **)outError;

// Moves the pointer.
// The pointer will be moved by |x| and |y|.
- (BOOL)moveRelativeDeltaX:(int)x deltaY:(int)y error:(NSError **)outError;

// Sends some text.
- (BOOL)enterText:(NSString *)text error:(NSError **)outError;

// Send up/down for a given key
- (BOOL)sendAction:(int)action forKey:(int)keyCode error:(NSError **)outError;

// Simulates a "click" on a given key by sending a down action followed by an
// up action for the key.
- (BOOL)sendClickForKey:(int)keyCode error:(NSError **)outError;

// Sends a URL for display.
- (BOOL)gotoUrlString:(NSString *)urlString error:(NSError **)outError;

// Sends a scrolling command.
- (BOOL)scrollDeltaX:(int)x deltaY:(int)y error:(NSError **)outError;

// Zooms. Pass NO to zoom out.
- (BOOL)zoomIn:(BOOL)isIn error:(NSError **)outError;

- (void)close;

// @protected: subclasses should implement to actually send the data.
// All the above methods filter through to it.
- (void)sendData:(const void *)data
            size:(NSUInteger)size
           error:(NSError **)outError;

@end

extern NSString * const AnymoteErrorDomain;

// malloc returned NULL
#define kAnymoteErrorMalloc                   1
// Can't serialize anymote message
#define kAnymoteErrorCantSerializeMessage     2
