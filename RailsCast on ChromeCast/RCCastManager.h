//
//  RCCastManager.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RCCastFilterType) {
  RCCastFilterNone,
  RCCastFilterActiveRecord,
  RCCastFilterRouting,
  RCCastFilterController,
  RCCastFilterView
};

@interface RCCastManager : NSObject

@property (nonatomic, strong) NSArray *railsCasts;
@property (nonatomic, strong) NSArray *filteredCasts;


+ (instancetype)manager;
- (void)downloadFeed;
- (void)filterCastsWithFilterType:(RCCastFilterType)filterType;

@end
