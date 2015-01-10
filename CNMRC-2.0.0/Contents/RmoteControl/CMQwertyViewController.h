//
//  CMQwertyViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMQwertyViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *qwertyTextField;
@property (weak, nonatomic) IBOutlet UIView *inputAccessoryView;
@property (strong, nonatomic) NSString *currentInputMode;

- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteTVCharacter:(id)sender;

@end


  