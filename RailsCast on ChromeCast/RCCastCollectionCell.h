//
//  RCCastCollectionCell.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCCast;

@interface RCCastCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *castImageView;

- (void)setCast:(RCCast*)cast;

@end
