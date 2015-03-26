//
//  CMPlayerViewController.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 26..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMPlayerViewController.h"

@interface CMPlayerViewController () <CMPlayerViewDelegate>
- (void)addPlayer;
- (void)removePlayer;
@end

@implementation CMPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 뷰 로테이션(-90도).
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI/2);
    self.view.transform = rotationTransform;
    
    [self addPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPlayer {
    self.playerView.delegate = self;
    
    NSURL *URL = [NSURL URLWithString:@"http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"];
    [self.playerView setVideoURL:URL];
    [self.playerView prepareAndPlayAutomatically:YES];
}

- (void)removePlayer {
    [self.playerView clean];
}

#pragma mark - Player View Delegate Methods

- (void)playerWillEnterFullscreen {
    
}

- (void)playerWillLeaveFullscreen {
    
}

- (void)playerDidEndPlaying {
    [self.playerView clean];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [self.playerView clean];
}

@end
