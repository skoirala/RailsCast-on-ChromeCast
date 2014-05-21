//
//  VideoViewController.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "VideoViewController.h"
#import "constants.h"
#import "FullScreenVideoController.h"
#import "VideoViewController.h"

@interface VideoViewController ()
@property (nonatomic) BOOL scrubbing;
@property (nonatomic) BOOL playerViewState;
@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.imageView.image = self.originalImage;
  self.descriptionTextView.text = self.castToPlay.castDescription;
  
  [self.playerView prepareToPlayFromurl:[NSURL URLWithString:self.castToPlay.enclosureUrl]];
  self.playerView.hidden = YES;
  self.playPauseButton.enabled = NO;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcCastPlayerReadyToPlayNotification:) name:kRCCastPlayerViewReadyToPlayNotification object:nil];
  
  __weak VideoViewController *weakSelf = self;
  [self.playerView setTimeObserver:^(CMTime time){
    dispatch_async(dispatch_get_main_queue(), ^{
      int seconds = (int)(CMTimeGetSeconds(time));
      int minutes = seconds / 60;
      int remainingSeconds = seconds % 60;
      weakSelf.timeLabel.text = [NSString stringWithFormat:@"%0.2d:%0.2d", minutes, remainingSeconds];
      float minValue = [weakSelf.scrubber minimumValue];
      float maxValue = [ weakSelf.scrubber maximumValue];
      double timeInSeconds = CMTimeGetSeconds(time);
      double totalTime = CMTimeGetSeconds(weakSelf.playerView.totalDuration);
      float value = (maxValue - minValue) * timeInSeconds / totalTime  + minValue;
      [weakSelf.scrubber setValue:value];
    });
  }];
      // Do any additional setup after loading the view.
}

- (void)rcCastPlayerReadyToPlayNotification:(NSNotification*)notification{
  if(self.imageView){
    [self.indicatorView removeFromSuperview];
    [self.imageView removeFromSuperview];
    self.playPauseButton.enabled = YES;
    self.playerView.hidden = NO;
  }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kRCCastPlayerViewReadyToPlayNotification object:nil];
  
  if([segue.identifier isEqual:@"FullPlayerView"]){
    
    FullScreenVideoController *fullScreenVideoController = [segue destinationViewController];
    [fullScreenVideoController setCast:self.castToPlay];
    if([self.playerView isPlaying]){
      [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
      [self.playerView playPause];
    }
  }
}

- (void)playPause:(id)sender{
  [self.playerView playPause];
  if(self.playerView.playing){
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
  CMTime currentTime = self.playerView.totalDuration;
    double durationInSeconds = CMTimeGetSeconds(currentTime);
  
    CMTime newTime = CMTimeMakeWithSeconds(scrubber.value * durationInSeconds,currentTime.timescale);
    [self.playerView seekToTime:newTime];
}


- (void)scrubberTouchDownAction:(id)sender{
  _playerViewState = self.playerView.playing;
  
  if([self.playerView isPlaying]){
    [self.playerView playPause];
  }
}

- (void)scrubberTouchUpInsideAction:(id)sender{
  if(self.playerViewState == YES){
    [self.playerView playPause];
  }
}
- (NSUInteger)supportedInterfaceOrientations{
  return UIInterfaceOrientationMaskPortrait;
}

- (void)exitFullScreenVideoMode:(UIStoryboardSegue *)segue{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcCastPlayerReadyToPlayNotification:) name:kRCCastPlayerViewReadyToPlayNotification object:nil];
}

@end
