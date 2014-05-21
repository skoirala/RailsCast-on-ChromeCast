//
//  FullScreenVideoController.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 21/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCCast;
@interface FullScreenVideoController : UIViewController

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *controlBarButtomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *controlBarHeightConstraint;
@property (nonatomic, strong) RCCast *cast;
@property (nonatomic, weak) IBOutlet UISlider *scrubber;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;


- (IBAction)scrubberTouchDownAction:(id)sender;
- (IBAction)scrubberTouchUpInsideAction:(id)sender;

- (IBAction)scrubberDragged:(UISlider*)scrubber;
- (IBAction)playPause:(id)sender;


- (IBAction)playVideo;



@end
