//
//  RCCastCollectionCell.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCastCollectionCell.h"
#import "RCCast.h"

@implementation RCCastCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews{
  [super layoutSubviews];
  [self.titleLabel preferredMaxLayoutWidth];
  [super layoutSubviews];
}


- (void)prepareForReuse{
  [super prepareForReuse];
  self.titleLabel.text = @"";
  self.durationLabel.text = @"";
  self.castImageView.image = nil;
}

- (void)setCast:(RCCast *)cast{
  self.titleLabel.text = cast.title;
  self.durationLabel.text = cast.duration;
  
}


@end
