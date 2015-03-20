//
//  CMKeyboardViewController.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMKOKeyboardView.h"

@interface CMKeyboardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *KeyboardBackground;
@property (weak, nonatomic) IBOutlet CMKOKeyboardView *koKeyboard;

- (IBAction)cancelAction:(id)sender;

@end
