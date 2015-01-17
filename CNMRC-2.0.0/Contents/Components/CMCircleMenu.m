//
//  CMCircleMenu.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 16..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMCircleMenu.h"
#import <QuartzCore/QuartzCore.h>

@implementation CMCircleMenu

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 버튼 애니메이션.
    [self bounceAnimation];
}

- (void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenu:menuItem:menuIndex:)])
        {
            [self.delegate circleMenu:self menuItem:nil menuIndex:CIRCLE_MENU_BUTTON_TAG];
        }
    }
}

- (IBAction)closeCircleMenuAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenu:menuItem:menuIndex:)])
    {
        UIButton *item = (UIButton *)sender;
        [self.delegate circleMenu:self menuItem:item menuIndex:item.tag];
    }
}

- (void)bounceAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.01), @(.2), @(0.9), @(1.3), @(1)];
    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(0.7), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.5;
    animation.delegate = self;
    [self.volumeButton.layer addAnimation:animation forKey:@"bouce"];
    [self.touchPadButton.layer addAnimation:animation forKey:@"bouce"];
    [self.mirrorButton.layer addAnimation:animation forKey:@"bouce"];
    [self.keyPadButton.layer addAnimation:animation forKey:@"bouce"];
    [self.settingsButton.layer addAnimation:animation forKey:@"bouce"];
}

@end
