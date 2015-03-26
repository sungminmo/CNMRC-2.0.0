//
//  CMPlayerView.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 26..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMPlayerViewDelegate;

@interface CMPlayerView : UIView

@property (strong, nonatomic) NSURL *videoURL;
@property (assign, nonatomic) NSInteger controllersTimeoutPeriod;
@property (weak, nonatomic) id<CMPlayerViewDelegate> delegate;

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically;
- (void)clean;
- (void)play;
- (void)pause;
- (void)stop;

- (BOOL)isPlaying;

@end

@protocol CMPlayerViewDelegate <NSObject>

@optional
- (void)playerDidPause;
- (void)playerDidResume;
- (void)playerDidEndPlaying;
- (void)playerWillEnterFullscreen;
- (void)playerDidEnterFullscreen;
- (void)playerWillLeaveFullscreen;
- (void)playerDidLeaveFullscreen;

- (void)playerFailedToPlayToEnd;
- (void)playerStalled;

@end
