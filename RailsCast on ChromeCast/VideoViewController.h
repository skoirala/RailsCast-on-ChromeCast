//
//  VideoViewController.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCast.h"
#import "RCCastPlayerView.h"

@interface VideoViewController : UIViewController
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) RCCast *castToPlay;
@property (nonatomic, weak) IBOutlet RCCastPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (nonatomic, weak) IBOutlet UISlider *scrubber;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;

- (IBAction)scrubberTouchDownAction:(id)sender;
- (IBAction)scrubberTouchUpInsideAction:(id)sender;

- (IBAction)scrubberDragged:(UISlider*)scrubber;
- (IBAction)playPause:(id)sender;

- (IBAction)exitFullScreenVideoMode:(UIStoryboardSegue*)segue;

@end
