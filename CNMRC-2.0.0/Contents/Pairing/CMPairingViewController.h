//
//  CMPairingViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

@protocol CMPairingViewControllerDelegate;
@class PoloConnection;

@interface CMPairingViewController : CMBaseViewController

@property(assign, nonatomic) id<NSObject, CMPairingViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *textFieldBackgroud;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

- (IBAction)joinAction:(id)sender;

@end

@protocol CMPairingViewControllerDelegate

- (void)didCancelPairing;
- (BOOL)continuePairingWithSecret:(NSString *)secret;

@optional
- (void)pairingViewController:(CMPairingViewController *)controller pairedSuccessfully:(BOOL)pairedOrFailed;
@end
