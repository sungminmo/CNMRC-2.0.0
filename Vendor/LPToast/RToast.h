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

#import <UIKit/UIKit.h>

// This is spin-off from GIPToast that enables showing toast indefinitely with
// spinning indicator.
@interface RToast : UIView {
@private
  UILabel *message_;
  UIActivityIndicatorView *spinner_;
}

// Displays the specified |message| on screen for |duration| seconds.
+ (void)showToast:(NSString *)message forDuration:(NSTimeInterval)duration;

// Displays the spcified |message| on screen with spinning indicator
// indefinitely until it is explicitly hidden with hide or other toast with
// duration is being shown.
+ (void)showToastWithSpinner:(NSString *)message;

// Hides the toast.
+ (void)hide;

@end
