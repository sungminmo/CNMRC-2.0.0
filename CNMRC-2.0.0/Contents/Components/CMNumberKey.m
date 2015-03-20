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

- (IBAction)keyAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    // 0 ~ 9.
    if (button.tag < 10)
    {
        NSString *highlightedImageName = [NSString stringWithFormat:@"No_%ld_H", (long)button.tag];
        UIImage *highlightedImage = [UIImage imageNamed:highlightedImageName];
        UIImageView *highlightedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y - 75, 48.5, 117.5)];
        highlightedImageView.center = CGPointMake(button.center.x, highlightedImageView.center.y);
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
