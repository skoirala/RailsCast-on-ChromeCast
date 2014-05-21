//
//  FullScreenVideoController.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 21/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "FullScreenVideoController.h"
#import "RCCastPlayerView.h"
#import "constants.h"
#import "RCCast.h"

@interface FullScreenVideoController ()
@property (nonatomic) BOOL playerViewState;
@end

@implementation FullScreenVideoController{
  BOOL controlHidden;
}

- (void)playVideo{
   RCCastPlayerView *playerView = (RCCastPlayerView*)self.view;
  [playerView playPause];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
  RCCastPlayerView *playerView = (RCCastPlayerView*)self.view;
  [playerView  prepareToPlayFromurl:[NSURL URLWithString:self.cast.enclosureUrl]];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideControl:)];
  [self.view addGestureRecognizer:tap];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcCastPlayerReadyToPlayNotification:) name:RCCastPlayerViewReadyToPlayNotification object:nil];
  __weak FullScreenVideoController *weakSelf = self;
  __weak RCCastPlayerView *weakPlayer = playerView;
  [playerView setTimeObserver:^(CMTime time){
    dispatch_async(dispatch_get_main_queue(), ^{
      int seconds = (int)(CMTimeGetSeconds(time));
      int minutes = seconds / 60;
      int remainingSeconds = seconds % 60;
      weakSelf.timeLabel.text = [NSString stringWithFormat:@"%0.2d:%0.2d", minutes, remainingSeconds];
      float minValue = [weakSelf.scrubber minimumValue];
      float maxValue = [ weakSelf.scrubber maximumValue];
      double timeInSeconds = CMTimeGetSeconds(time);
      double totalTime = CMTimeGetSeconds(weakPlayer.totalDuration);
      float value = (maxValue - minValue) * timeInSeconds / totalTime  + minValue;
      [weakSelf.scrubber setValue:value];
    });
  }];
  // Do any additional setup after loading the view.
}

- (void)rcCastPlayerReadyToPlayNotification:(NSNotification*)notification{
  self.playPauseButton.enabled = YES;
}




- (void)showHideControl:(UITapGestureRecognizer*)tap{
  float constant;
  
  if(!controlHidden){
    constant = - self.controlBarHeightConstraint.constant;
  }else{
    constant = 0;
  }
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.controlBarButtomConstraint.constant = constant;
    [self.view layoutIfNeeded];
  } completion:^(BOOL finished) {
    controlHidden = !controlHidden;
  }];

}


- (void)playPause:(id)sender{
  RCCastPlayerView *playerView = (RCCastPlayerView*)self.view;
  
  [playerView playPause];
  if(playerView.playing){
    [sender setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
  }else{
    [sender setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)scrubberDragged:(UISlider *)scrubber{
  RCCastPlayerView *playerView = (RCCastPlayerView*)self.view;

  CMTime currentTime = playerView.totalDuration;
  double durationInSeconds = CMTimeGetSeconds(currentTime);
  
  CMTime newTime = CMTimeMakeWithSeconds(scrubber.value * durationInSeconds,currentTime.timescale);
  [playerView seekToTime:newTime];
}


- (void)scrubberTouchDownAction:(id)sender{
   RCCastPlayerView *playerView = (RCCastPlayerView*)self.view;
  _playerViewState = playerView.playing;
  
  if([playerView isPlaying]){
    [playerView playPause];
  }
}

- (void)scrubberTouchUpInsideAction:(id)sender{
  RCCastPlayerView *playerView = (RCCastPlayerView*)self.view;

  if(self.playerViewState == YES){
    [playerView playPause];
  }
}


- (BOOL)prefersStatusBarHidden{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
  return UIInterfaceOrientationMaskLandscape;
}

@end
