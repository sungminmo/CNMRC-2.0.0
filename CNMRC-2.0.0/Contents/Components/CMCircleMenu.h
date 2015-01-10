//
//  CMCircleMenu.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 16..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CIRCLE_MENU_BUTTON_TAG 100

@protocol CMCircleMenuDelegate;

@interface CMCircleMenu : UIView

@property (assign, nonatomic) id<CMCircleMenuDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *volumeButton;
@property (weak, nonatomic) IBOutlet UIButton *touchPadButton;
@property (weak, nonatomic) IBOutlet UIButton *mirrorButton;
@property (weak, nonatomic) IBOutlet UIButton *keyPadButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

- (IBAction)closeCircleMenuAction:(id)sender;

@end

@protocol CMCircleMenuDelegate <NSObject>
- (void)circleMenu:(CMCircleMenu *)circleMenu menuItem:(UIButton *)item menuIndex:(NSUInteger)index;
@end
