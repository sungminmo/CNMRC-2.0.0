//
//  CMCVPad.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMCVPad.h"

@implementation CMCVPad

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupLayout];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout
{

}

- (IBAction)buttonAction:(id)sender
{
    //[self buttonAnimation:sender];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cvPad:selectedKey:)])
    {
        [self.delegate cvPad:self selectedKey:sender];
    }
}

- (void)buttonAnimation:(id)sender
{
    NSArray *images = @[[UIImage imageNamed:@"TapPress_1"],
                        [UIImage imageNamed:@"TapPress_2"],
                        [UIImage imageNamed:@"TapPress_3"],
                        [UIImage imageNamed:@"TapPress_4"]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 65.0, 65.0)];
    imageView.center = [(UIButton *)sender center];
    imageView.animationImages = images;
    imageView.animationDuration = 0.5;
    imageView.animationRepeatCount = 1; // 0 = nonStop repeat
    [imageView startAnimating];
    
    [self insertSubview:imageView belowSubview:self.volumeUpButton];
    [self performSelector:@selector(removeAnimation:) withObject:imageView afterDelay:1];
}

- (void)removeAnimation:(id)obj
{
    [obj removeFromSuperview];
}

@end
