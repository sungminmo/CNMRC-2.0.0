//
//  CMKeyboardViewController.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMKOKeyboardView.h"
#import "CMENKeyboardView.h"
#import "CMNumberKeyboardView.h"

@interface CMKeyboardViewController : UIViewController <CMKeyboardDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *KeyboardBackground;
@property (weak, nonatomic) IBOutlet CMKOKeyboardView *koKeyboard;
@property (weak, nonatomic) IBOutlet CMENKeyboardView *enKeyboard;
@property (weak, nonatomic) IBOutlet CMNumberKeyboardView *numberKeyboard;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteTVCharacter:(id)sender;

@end
