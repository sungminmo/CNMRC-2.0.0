//
//  CMSetIPViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 16..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSetIPViewController.h"
#import "DQAlertView.h"

@interface CMSetIPViewController ()

@end

@implementation CMSetIPViewController

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
    
    self.titleLabel.text = @"IP 주소 입력";
    
    if (isiOS7)
    {
        self.textFieldBackgroud.center = CGPointMake(self.textFieldBackgroud.center.x, self.textFieldBackgroud.center.y + 20.0);
        self.ipTextField.center = CGPointMake(self.ipTextField.center.x, self.ipTextField.center.y + 20.0);
    }
    self.textFieldBackgroud.layer.borderWidth = 1.0;
    self.textFieldBackgroud.layer.cornerRadius = 9.0;
    self.textFieldBackgroud.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.ipTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setIpTextField:nil];
    [super viewDidUnload];
}

// 박스 연결.
- (IBAction)connectBox:(id)sender
{
    // IP 확인.
    if ([self.ipTextField.text isValidIPAddress])
    {
        _address = self.ipTextField.text;
        [_delegate setIPViewControllerDidEnd:self];
    }
    else
    {
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                            message:@"올바른 IP 주소를 입력하십시오!"
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            Debug(@"OK Clicked");
            self.ipTextField.text = nil;
            [self.ipTextField becomeFirstResponder];
        };
        
        [alertView show];
    }
}


@end
