//
//  CMKOKeyboardView.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMKOKeyboardView.h"

@implementation CMKOKeyboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSString *className = NSStringFromClass([self class]);
    [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    [self addSubview:self.view];
}

@end
