//
//  CMTouchPad.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTouchPad.h"

static const int kSimultaneousTouchesCount = 5;

@implementation CMTouchPad

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

}

- (IBAction)buttonAction:(id)sender
{
    //[self buttonAnimation:sender];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchPad:selectedKey:)])
    {
        [self.delegate touchPad:self selectedKey:sender];
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
    
    [self insertSubview:imageView belowSubview:self.topButton];
    [self performSelector:@selector(removeAnimation:) withObject:imageView afterDelay:1];
}

- (void)removeAnimation:(id)obj
{
    [obj removeFromSuperview];
}

- (void)touchAnimation:(CGPoint)point
{
    NSArray *images = @[[UIImage imageNamed:@"tappress01@2x.png"],
                        [UIImage imageNamed:@"tappress02@2x.png"],
                        [UIImage imageNamed:@"tappress03@2x.png"],
                        [UIImage imageNamed:@"tappress04@2x.png"]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 65.0, 65.0)];
    imageView.center = point;
    imageView.animationImages = images;
    imageView.animationDuration = 0.2;
    imageView.animationRepeatCount = 1; // 0 = nonStop repeat
    [imageView startAnimating];
    
    [self insertSubview:imageView belowSubview:self.topButton];
    [self performSelector:@selector(removeAnimation:) withObject:imageView afterDelay:0.2];
}

- (UIView *)viewClosedToLocation:(CGPoint)point
{
    UIView *closest = nil;
    float distanceSquaredOfClosest = INT_MAX;
//    for (UIView *v in tapImagesThisTap_) {
//        CGPoint center = [v center];
//        CGFloat dx = center.x - point.x;
//        CGFloat dy = center.y - point.y;
//        CGFloat distanceSquared = (dx*dx) + (dy*dy);
//        if (distanceSquared < distanceSquaredOfClosest) {
//            closest = v;
//            distanceSquaredOfClosest = distanceSquared;
//        }
//    }
    return closest;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(touchPadDidBeginTracking:)])
    {
        [_delegate touchPadDidBeginTracking:self];
    }
    [[self touchHandler] touchesBegan:touches withEvent:event];
//    int i = 0;
//    for (UITouch *touch in touches)
//    {
//        if (i >= kSimultaneousTouchesCount)
//        {
//            break;
//        }
//        CGPoint point = [touch locationInView:self];
//        UIView *tapView = [tapImagesMaster_ objectAtIndex:i];
//        [tapImagesThisTap_ addObject:tapView];
//        [tapView setCenter:point];
//        [self addSubview:tapView];
//        i++;
//    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self touchHandler] touchesMoved:touches withEvent:event];
    int i = 0;
    for (UITouch *touch in touches)
    {
        if (kSimultaneousTouchesCount <= i)
        {
            break;
        }
        CGPoint current = [touch locationInView:self];
        CGPoint previous = [touch previousLocationInView:self];
//        UIView *view = [self viewClosedToLocation:previous];
//        [view setCenter:current];

        if (CGRectContainsPoint(self.bounds, current))
        {
            [self touchAnimation:current];
        }
        i++;
    }
}

- (void)touchesEndedOrCancelled
{
//    [tapImagesThisTap_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [tapImagesThisTap_ removeAllObjects];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self touchHandler] touchesEnded:touches withEvent:event];
    if ([_delegate respondsToSelector:@selector(touchPadDidEndTracking:)])
    {
        [_delegate touchPadDidEndTracking:self];
    }
    [self touchesEndedOrCancelled];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self touchHandler] touchesCancelled:touches withEvent:event];
    if ([_delegate respondsToSelector:@selector(touchPadDidEndTracking:)]) {
        [_delegate touchPadDidEndTracking:self];
    }
    [self touchesEndedOrCancelled];
}

@end
