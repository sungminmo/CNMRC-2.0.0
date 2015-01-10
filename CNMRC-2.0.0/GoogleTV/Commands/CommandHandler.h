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

@class CommandSender;

// A cross platform class to wrap a command Sender. CommandHandler translates
// commands at the UI level to VKey, VModifier commands.
@interface CommandHandler : NSObject {
@private
  CommandSender *sender_;
}

@property (nonatomic, retain, readonly) CommandSender *sender;
// Designated initializer.
- (id)initWithSender:(CommandSender *)sender;

- (void)sendApplications;

- (void)sendBack;

- (void)sendBackspace;

- (void)sendBookmarks;

- (void)sendChannelDown;

- (void)sendChannelUp;

- (void)sendDown;

- (void)sendDvr;

- (void)sendEnter;

- (void)sendEscape;

- (void)sendFastForward;

- (void)sendForward;

- (void)sendGuide;

- (void)sendHome;

- (void)sendInfo;

- (void)sendLeft;

- (void)sendLiveTV;

- (void)sendMute;

- (void)sendNextChapter;

- (void)sendNotifications;

- (void)sendOmnibox;

- (void)sendPageDown;

- (void)sendPageUp;

- (void)sendPlayPause;

- (void)sendPower;

- (void)sendPreviousChapter;

- (void)sendRecall;

- (void)sendRecord;

- (void)sendRewind;

- (void)sendRight;

- (void)sendSkipBack;

- (void)sendSkipForward;

- (void)sendSpace;

- (void)sendStop;

- (void)sendText:(NSString *)text;

- (void)sendUp;

- (void)sendVolumeDown;

- (void)sendVolumeUp;

- (void)sendZapper;

- (void)sendZoomIn;

- (void)sendZoomOut;

// ## These are here to completely wrap the sender, to keep our abstractions
// layered.
- (void)click;

- (void)moveRelativeDeltaX:(int)x deltaY:(int)y;

- (void)scrollDeltaX:(int)x deltaY:(int)y;
@end
