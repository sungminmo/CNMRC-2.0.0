//
//  CMPairingViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMPairingViewController.h"
#import "SIAlertView.h"

@interface CMPairingViewController ()

@end

@implementation CMPairingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"코드 입력";
    
    self.textFieldBackgroud.layer.borderWidth = 1.0;
    self.textFieldBackgroud.layer.cornerRadius = 9.0;
    self.textFieldBackgroud.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.codeTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 코드 입력.
- (IBAction)joinAction:(id)sender
{
    
    if  ([self.codeTextField.text isEmpty])
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"알림" andMessage:@"코드를 입력하십시오!"];
        [alertView addButtonWithTitle:@"확인"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  Debug(@"OK Clicked");
                                  [self.codeTextField becomeFirstResponder];
                              }];
        alertView.cornerRadius = 10;
        alertView.buttonFont = [UIFont boldSystemFontOfSize:15];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
    else
    {
        if ([_delegate continuePairingWithSecret:[self.codeTextField text]])
        {
            [self.codeTextField setEnabled:NO];
            
            //[AppDelegate.container popViewControllerAnimated:YES];
        }
    }
}

@end
