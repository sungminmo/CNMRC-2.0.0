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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setupLayout
{
    // 백그라운드 패드 이미지.
    UIImage *bgImage = [UIImage imageNamed:DeviceSpecificSetting(@"chvol_bg@2x.png", @"chvol_bg01@2x.png")];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgImageView.image = bgImage;
    [self insertSubview:bgImageView atIndex:0];
}

- (IBAction)buttonAction:(id)sender
{
    [self buttonAnimation:sender];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cvPad:selectedKey:)])
    {
        [self.delegate cvPad:self selectedKey:sender];
    }
}

- (void)buttonAnimation:(id)sender
{
    NSArray *images = @[[UIImage imageNamed:@"tappress01@2x.png"],
                        [UIImage imageNamed:@"tappress02@2x.png"],
                        [UIImage imageNamed:@"tappress03@2x.png"],
                        [UIImage imageNamed:@"tappress04@2x.png"]];
    
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
