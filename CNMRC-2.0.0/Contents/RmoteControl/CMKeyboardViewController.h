//
//  CMKeyboardViewController.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMKeyboardView.h"

@interface CMKeyboardViewController : UIViewController <CMKeyboardDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *KeyboardBackground;
@property (strong, nonatomic) CMKeyboardView *keyboard;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (assign, nonatomic) CMKeyboardType currentInputMode;

- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteTVCharacter:(id)sender;

@end
