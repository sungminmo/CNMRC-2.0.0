//
//  UIButton+Sound.m
//  UIButtonSound
//
//  Created by Fred Showell on 6/01/13.
//  Copyright (c) 2013 Fred Showell. All rights reserved.
//

#import "UIButton+Sound.h"
#import <objc/runtime.h>

static char const * const kTapSoundKey = "kTapSoundKey";
static char const * const kReleaseSoundKey = "kReleaseSoundKey";

@implementation UIButton (Sound)

- (void)addSoundTitled:(NSString *)filename forUIControlEvent:(UIControlEvents)controlEvents
{
    //set appropriate category for UI sounds - do not mute other playing audio
    [[AVAudioSession sharedInstance] setCategory:@"AVAudioSessionCategoryAmbient" error:nil];
    
    NSString *file = [filename stringByDeletingPathExtension];
    NSString *extension = [filename pathExtension];
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:file withExtension:extension];
    
    NSError *error = nil;

    if (controlEvents == UIControlEventTouchDown)
    {
          
        self.tapSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        [self.tapSound prepareToPlay];
        
        if (error){
            NSLog(@"couldn't add sound - error: %@", error);
        }
        
        else
            
        [self addTarget:self.tapSound action:@selector(play) forControlEvents:controlEvents];
    }
    
    else if (controlEvents == UIControlEventTouchUpInside)
    {
        self.releaseSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        [self.releaseSound prepareToPlay];
        
        if (error){
            NSLog(@"couldn't add sound - error: %@", error);
        }
        else
            [self addTarget:self.releaseSound action:@selector(play) forControlEvents:controlEvents];
    }

}


#pragma mark - Associated objects setters/getters

-(void) setTapSound:(AVAudioPlayer *)tapSound
{
    objc_setAssociatedObject(self, kTapSoundKey, tapSound, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void) setReleaseSound:(AVAudioPlayer *)releaseSound
{
    objc_setAssociatedObject(self, kReleaseSoundKey, releaseSound, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(AVAudioPlayer*) tapSound
{
    return objc_getAssociatedObject(self, kTapSoundKey);
}

-(AVAudioPlayer*) releaseSound
{
    return objc_getAssociatedObject(self, kReleaseSoundKey);
}

- (void)vibrate
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

// "touchUpInside"인지 감지하고 만약 설정되어 있다면 사운드를 플레이 한다.
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.touchInside)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"tap-muted" withExtension:@"aif"];
        
//        NSError *error = nil;
//        
//        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//        player.volume = 1;
//        [player prepareToPlay];
//        [player play];
//        
//        if (error)
//        {
//            NSLog(@"couldn't add sound - error: %@", error);
//        }
        
        // TODO: 설정과 연동해야 함!
        // !!!: 사운드와 진동은 시스템 설정이 우선이다!!!
        
        if (AppInfo.isSound)
        {
            // 버튼 사운드.
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID ((CFURLRef)CFBridgingRetain(url), &soundID);
            AudioServicesPlaySystemSound(soundID);
        }
        
        if (AppInfo.isVibration == YES)
        {
            // 버튼 진동.
            [self vibrate];
        }
    }
}

@end
