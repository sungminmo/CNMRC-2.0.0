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

#import "CommandHandler.h"
#import "CommandSender.h"
#include "keycodes.pb.h"

using namespace anymote::messages;

@implementation CommandHandler
@synthesize sender = sender_;

- (id)initWithSender:(CommandSender *)sender {
  self = [super init];
  if (self != nil) {
    sender_ = [sender retain];
  }
  return self;
}

- (void)dealloc {
  [sender_ release];
  [super dealloc];
}

- (void)sendApplications {
  [sender_ gotoUrlString:@"launcher://apps" error:NULL];
}

- (void)sendEscape {
  [sender_ sendClickForKey:KEYCODE_ESCAPE error:NULL];
}

- (void)sendZapper {
  [sender_ sendClickForKey:KEYCODE_MENU error:NULL];
}

- (void)sendPageDown {
  [sender_ sendClickForKey:KEYCODE_PAGE_DOWN error:NULL];
}

- (void)sendPageUp {
  [sender_ sendClickForKey:KEYCODE_PAGE_UP error:NULL];
}

- (void)sendSpace {
  [sender_ sendClickForKey:KEYCODE_SPACE error:NULL];
}

- (void)sendBackspace {
  [sender_ sendClickForKey:KEYCODE_BACK error:NULL];
}

- (void)sendBookmarks {
  [sender_ gotoUrlString:@"launcher://bookmarks" error:NULL];
}

- (void)sendHome {
  [sender_ sendClickForKey:KEYCODE_HOME error:NULL];
}

// or ALT + Left Arrow
- (void)sendBack {
  [sender_ sendClickForKey:KEYCODE_BACK error:NULL];
}

// or ALT + Right Arrow
- (void)sendForward {
}

- (void)sendPlayPause {
  [sender_ sendClickForKey:KEYCODE_MEDIA_PLAY_PAUSE error:NULL];
}

- (void)sendPower {
  [sender_ sendClickForKey:KEYCODE_POWER error:NULL];
}

- (void)sendGuide {
  [sender_ sendClickForKey:KEYCODE_GUIDE error:NULL];
}

- (void)sendDvr {
  [sender_ sendClickForKey:KEYCODE_DVR error:NULL];
}

- (void)sendRewind {
  [sender_ sendClickForKey:KEYCODE_MEDIA_REWIND error:NULL];
}

- (void)sendSkipBack {
  [sender_ sendClickForKey:KEYCODE_MEDIA_SKIP_BACK error:NULL];
}

- (void)sendFastForward {
  [sender_ sendClickForKey:KEYCODE_MEDIA_FAST_FORWARD error:NULL];
}

- (void)sendSkipForward {
  [sender_ sendClickForKey:KEYCODE_MEDIA_SKIP_FORWARD error:NULL];
}

- (void)sendRecord {
  [sender_ sendClickForKey:KEYCODE_MEDIA_RECORD error:NULL];
}

- (void)sendEnter {
  [sender_ sendClickForKey:KEYCODE_ENTER error:NULL];
}

- (void)sendUp {
  [sender_ sendClickForKey:KEYCODE_DPAD_UP error:NULL];
}

- (void)sendDown {
  [sender_ sendClickForKey:KEYCODE_DPAD_DOWN error:NULL];
}

- (void)sendLeft {
  [sender_ sendClickForKey:KEYCODE_DPAD_LEFT error:NULL];
}

- (void)sendRight {
  [sender_ sendClickForKey:KEYCODE_DPAD_RIGHT error:NULL];
}

// Android calls this NavBar, but that term is too overloaded on iPhone.
- (void)sendOmnibox {
  //[sender_ sendVKey:VKEY_INVALID modifiers:KMOD_META];
}

- (void)sendStop {
  [sender_ sendClickForKey:KEYCODE_MEDIA_STOP error:NULL];
}

- (void)sendText:(NSString *)text {
  if ([text isEqual:@" "]) {
    // 7/5/09 - Experiments show -[enterText:@" "] was ignored.
    // TODO(oster): check to make sure this kludge is still needed.
    [self sendSpace];
  } else {
    [sender_ enterText:text error:NULL];
  }
}

- (void)sendZoomIn {
  [sender_ zoomIn:YES error:NULL];
}

- (void)sendZoomOut {
  [sender_ zoomIn:NO error:NULL];
}

- (void)sendLiveTV {
  [sender_ sendClickForKey:KEYCODE_LIVE error:NULL];
}

- (void)sendChannelDown {
  [sender_ sendClickForKey:KEYCODE_CHANNEL_DOWN error:NULL];
}

- (void)sendChannelUp {
  [sender_ sendClickForKey:KEYCODE_CHANNEL_UP error:NULL];
}

- (void)sendMute {
  [sender_ sendClickForKey:KEYCODE_MUTE error:NULL];
}

- (void)sendNotifications {
  [sender_ gotoUrlString:@"launcher://notifications" error:NULL];
}

- (void)sendVolumeDown {
  [sender_ sendClickForKey:KEYCODE_VOLUME_DOWN error:NULL];
}

- (void)sendVolumeUp {
  [sender_ sendClickForKey:KEYCODE_VOLUME_UP error:NULL];
}

- (void)sendInfo {
  [sender_ sendClickForKey:KEYCODE_INFO error:NULL];
}

- (void)sendNextChapter {
  [sender_ sendClickForKey:KEYCODE_MEDIA_NEXT error:NULL];
}

- (void)sendPreviousChapter {
  [sender_ sendClickForKey:KEYCODE_MEDIA_PREVIOUS error:NULL];
}

- (void)sendRecall {
  //[sender_ sendVKey:VKEY_PREVCHAN modifiers:KMOD_NONE];
}

#pragma mark -

- (void)click {
  [sender_ sendClickWithError:NULL];
}

- (void)moveRelativeDeltaX:(int)x deltaY:(int)y {
  [sender_ moveRelativeDeltaX:x deltaY:y error:NULL];
}

- (void)scrollDeltaX:(int)x deltaY:(int)y {
  [sender_ scrollDeltaX:x deltaY:y error:NULL];
}

@end
