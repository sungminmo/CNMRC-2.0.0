//
//  CMNumberKey.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMNumberKey.h"

@implementation CMNumberKey

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)keyAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    // 0 ~ 9.
    if (button.tag < 10)
    {
        NSString *highlightedImageName = [NSString stringWithFormat:@"n%d_press@2x.png", button.tag];
        UIImage *highlightedImage = [UIImage imageNamed:highlightedImageName];
        UIImageView *highlightedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x - 5, button.frame.origin.y - 81.5, 48.5, 117.5)];
        highlightedImageView.image = highlightedImage;
        [self addSubview:highlightedImageView];
        [self performSelector:@selector(removeHighlightedImageView:) withObject:highlightedImageView afterDelay:0.5];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedNumberKey:)])
    {
        [self.delegate selectedNumberKey:sender];
    }
}

- (void)removeHighlightedImageView:(UIImageView *)highlightedImageView
{
    [highlightedImageView removeFromSuperview];
}

@end
