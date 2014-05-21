//
//  RCCastPlayerView.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;


typedef void(^RCCastTimeObserver)(CMTime);


@interface RCCastPlayerView : UIView

- (void)prepareToPlayFromurl:(NSURL*)videoUrl;
- (void)playPause;
- (void)seekToTime:(CMTime)time;

@property (nonatomic, assign) RCCastTimeObserver timeObserver;
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;
@property (nonatomic, assign) CMTime totalDuration;

@end
