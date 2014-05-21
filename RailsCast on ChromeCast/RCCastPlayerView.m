//
//  RCCastPlayerView.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCastPlayerView.h"
#import "constants.h"


@interface RCCastPlayerView ()

@property(nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, readwrite) BOOL playing;
@property (nonatomic, strong) id handler;

@end

@implementation RCCastPlayerView

+ (Class)layerClass{
  return [AVPlayerLayer class];
}


- (void)setTimeObserver:(RCCastTimeObserver)timeObserver{
  _timeObserver = timeObserver;
  _handler = [_player addPeriodicTimeObserverForInterval:CMTimeMake(5, 10) queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) usingBlock:_timeObserver];

}

- (id)initWithFrame:(CGRect)frame{
  if(self = [super initWithFrame:frame]){
    [self setup];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
  if(self = [super initWithCoder:aDecoder]){
    [self setup];
  }
  return self;
}



- (void)setup{
  _player = [[AVPlayer alloc] init];
  AVPlayerLayer *playerLayer = (AVPlayerLayer*)self.layer;
  playerLayer.player = _player;
  playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

static void * kRCCastPlayerViewPlayerItemObservingContext = &kRCCastPlayerViewPlayerItemObservingContext;

- (void)prepareToPlayFromurl:(NSURL *)videoUrl{
   AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
  __weak RCCastPlayerView *weakSelf = self;
  
  [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
    NSError *error;
    AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
    if(error){
      NSLog(@"Error occured %@", error);
    }else{
      switch (status) {
        case AVKeyValueStatusLoaded:
          weakSelf.totalDuration = [asset duration];
          weakSelf.playerItem = [AVPlayerItem playerItemWithAsset:asset];
          [weakSelf.playerItem addObserver:weakSelf forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(kRCCastPlayerViewPlayerItemObservingContext)];
          [weakSelf.player replaceCurrentItemWithPlayerItem:weakSelf.playerItem];
          
          break;
        case AVKeyValueStatusFailed:
          NSLog(@"AVKeyValueStatusFailed");
          break;
        default:
          break;
      }
    }
  }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  __weak RCCastPlayerView *weakSelf = self;
  if([keyPath isEqualToString:@"status"] && context == kRCCastPlayerViewPlayerItemObservingContext){
    AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    if(status == AVPlayerItemStatusReadyToPlay){
      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRCCastPlayerViewReadyToPlayNotification object:weakSelf];
      });
    }
    [_playerItem removeObserver:self forKeyPath:@"status"];
    
  }
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)playPause{
  if(!self.playing)
    [self.player play];
  else
    [self.player pause];
  self.playing = !self.isPlaying;
}

- (void)seekToTime:(CMTime)time{
  [self.player seekToTime:time];
}

- (void)dealloc{
  if(_timeObserver){
    [_player removeTimeObserver:_handler];
    _timeObserver = NULL;
  }
  _playerItem = nil;
  _player = nil;
}

@end
