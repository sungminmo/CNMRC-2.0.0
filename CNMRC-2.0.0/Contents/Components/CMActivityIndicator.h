//
//  CMActivityIndicator.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 25..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMActivityIndicator : UIImageView

@property (nonatomic) CGFloat animationDuration;
@property (nonatomic, getter = isAnimating) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;
- (void)spin;

@end
