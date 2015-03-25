//
//  CMActivityIndicator.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 25..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@implementation CMActivityIndicator

@synthesize animationDuration = _animationDuration;
@synthesize animating = _animating;

#pragma mark - Init Methods

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 28, 28)];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (void)sharedSetup
{
    UIImage *loadingImage = [UIImage imageNamed:@"Loading"];
    self.image = loadingImage;
}

#pragma mark - Public Methods

- (void)setAnimating:(BOOL)animating
{
    _animating = animating;
    if (_animating)
    {
        [self startAnimating];
    }
    else
    {
        [self stopAnimating];
    }
}

- (BOOL)isAnimating
{
    CAAnimation *spinAnimation = [self.layer animationForKey:@"spinAnimation"];
    return (_animating || spinAnimation);
}

- (void)startAnimating
{
    _animating = YES;
    [self spin];
}

- (void)stopAnimating
{
    _animating = NO;
}

- (void)spin
{
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.byValue = [NSNumber numberWithFloat:2*M_PI];
    spinAnimation.duration = self.animationDuration;
    spinAnimation.delegate = self;
    [self.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
}

#pragma mark - Animation Delegates

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (_animating) {
        [self spin];
    }
}

#pragma mark - Property Methods

- (CGFloat)animationDuration
{
    if (!_animationDuration) {
        _animationDuration = 1.0f;
    }
    return _animationDuration;
}

@end
