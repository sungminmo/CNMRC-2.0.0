//
//  CMSetIPViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 16..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMSetIPViewControllerDelegate;

@interface CMSetIPViewController : CMBaseViewController

@property (weak, nonatomic) IBOutlet UIView *textFieldBackgroud;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property(assign, nonatomic) id <CMSetIPViewControllerDelegate> delegate;
@property(nonatomic, readonly) NSString *address;

- (IBAction)connectBox:(id)sender;

@end

@protocol CMSetIPViewControllerDelegate <NSObject>

- (void)setIPViewControllerDidEnd:(CMSetIPViewController *)controller;

@end
