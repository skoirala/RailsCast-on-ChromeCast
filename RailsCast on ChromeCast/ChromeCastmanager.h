//
//  ChromeCastmanager.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 21/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCCast;
@class GCKDevice;

@interface ChromeCastmanager : NSObject

@property (nonatomic, readonly) NSArray *allDevices;

- (void)seekToTimeInterval:(NSTimeInterval)timeInterval;

- (BOOL)isCurrentDevice:(GCKDevice*)device;

- (GCKDevice*)currentDevice;

- (void)connectToCurrentSelectedDevice;

- (void)setCurrentDevice:(GCKDevice*)device;

- (void)performScan;

- (void)playRCCast:(RCCast*)cast;

+ (ChromeCastmanager*)sharedManager;

- (void)pauseCast;

@end
