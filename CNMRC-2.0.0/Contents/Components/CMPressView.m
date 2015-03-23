//
//  CMPressView.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 23..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMPressView.h"

@implementation CMPressView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (void)setImage:(NSString *)imageName andLabel:(NSString *)key
{
    self.pressImageView.image = [UIImage imageNamed:imageName];
    self.pressLabel.text = key;
}

@end
