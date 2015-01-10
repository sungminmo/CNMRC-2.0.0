//
//  CMPlayerView.h
//  CNMRC
//
//  Created by lambert on 2014. 5. 15..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayerLayer;

@interface CMPlayerLayerView : UIView

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

- (void)setVideoFillMode:(NSString *)fillMode;

@end
