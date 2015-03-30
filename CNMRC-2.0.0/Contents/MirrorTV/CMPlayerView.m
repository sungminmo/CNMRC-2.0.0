//
//  CMPlayerView.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 26..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CMPlayerView () <AVAssetResourceLoaderDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *currentItem;

@property (strong, nonatomic) UIView *controllersView;
@property (strong, nonatomic) UILabel *airPlayLabel;

@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *fullscreenButton;
@property (strong, nonatomic) MPVolumeView *volumeView;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *remainingTimeLabel;
@property (strong, nonatomic) UILabel *liveLabel;

@property (strong, nonatomic) UIView *spacerView;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) NSTimer *controllersTimer;
@property (assign, nonatomic) BOOL seeking;
@property (assign, nonatomic) BOOL fullscreen;
@property (assign, nonatomic) CGRect defaultFrame;

@end

@implementation CMPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _defaultFrame = frame;
    [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void)setup
{
    // 노티피케이션 옵저버 등록.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerFailedToPlayToEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:nil];
    
    [self setBackgroundColor:[UIColor blackColor]];
}

#pragma mark - 퍼블릭 메서드 -

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically
{
    if (self.player)
    {
        [self stop];
    }
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    NSArray *keys = [NSArray arrayWithObject:@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
        [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
        
        if (playAutomatically) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self play];
            });
        }
    }];
    
    [self.player setAllowsExternalPlayback:YES];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.layer addSublayer:self.playerLayer];
    
    self.defaultFrame = self.frame;
    
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    [self.playerLayer setFrame:frame];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self.player seekToTime:kCMTimeZero];
    [self.player setRate:0.0f];
}

- (void)clean
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
    
    [self.player setAllowsExternalPlayback:NO];
    [self stop];
    [self.player removeObserver:self forKeyPath:@"rate"];
    //[self.currentItem removeObserver:self forKeyPath:@"status"];
    [self setPlayer:nil];
    [self setPlayerLayer:nil];
    [self removeFromSuperview];
}

- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
    
    if ([self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
}

- (void)stop
{
    if (self.player)
    {
        [self.player pause];
        [self.player seekToTime:kCMTimeZero];
    }
}

- (BOOL)isPlaying
{
    return [self.player rate] > 0.0f;
}

#pragma mark - AV Player Notifications and Observers

- (void)playerDidFinishPlaying:(NSNotification *)notification
{
    [self stop];
    
    if ([self.delegate respondsToSelector:@selector(playerDidEndPlaying)])
    {
        [self.delegate playerDidEndPlaying];
    }
}

- (void)playerFailedToPlayToEnd:(NSNotification *)notification
{
    [self stop];
    
    if ([self.delegate respondsToSelector:@selector(playerFailedToPlayToEnd)])
    {
        [self.delegate playerFailedToPlayToEnd];
    }
}

- (void)playerStalled:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(playerStalled)])
    {
        [self.delegate playerStalled];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        if (self.currentItem.status == AVPlayerItemStatusFailed)
        {
            if ([self.delegate respondsToSelector:@selector(playerFailedToPlayToEnd)])
            {
                [self.delegate playerFailedToPlayToEnd];
            }
        }
    }
}

@end
