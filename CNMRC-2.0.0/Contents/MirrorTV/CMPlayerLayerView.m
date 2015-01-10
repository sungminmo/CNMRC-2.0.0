//
//  CMPlayerView.m
//  CNMRC
//
//  Created by lambert on 2014. 5. 15..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import "CMPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CMPlayerLayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
	return (AVPlayerLayer *)self.layer;
}

- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
