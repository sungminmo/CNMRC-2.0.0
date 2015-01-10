//
//  CMControlPad.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 12..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMControlPad.h"

@implementation CMControlPad

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
    if (self) {
        // Initialization code
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

}

- (IBAction)buttonAction:(id)sender
{
    [self buttonAnimation:sender];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlPad:selectedKey:)])
    {
        [self.delegate controlPad:self selectedKey:sender];
    }
}

- (void)buttonAnimation:(id)sender
{
    NSArray *images = @[[UIImage imageNamed:@"tappress01@2x.png"],
                        [UIImage imageNamed:@"tappress02@2x.png.png"],
                        [UIImage imageNamed:@"tappress03@2x.png.png"],
                        [UIImage imageNamed:@"tappress04@2x.png.gif"]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 65.0, 65.0)];
    imageView.center = [(UIButton *)sender center];
    imageView.animationImages = images;
    imageView.animationDuration = 0.5;
    imageView.animationRepeatCount = 1; // 0 = nonStop repeat
    [imageView startAnimating];
    
    [self insertSubview:imageView belowSubview:self.playButton];
    [self performSelector:@selector(removeAnimation:) withObject:imageView afterDelay:1];
}

- (void)removeAnimation:(id)obj
{
    [obj removeFromSuperview];
}

@end
