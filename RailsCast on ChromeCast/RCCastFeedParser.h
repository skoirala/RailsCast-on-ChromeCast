//
//  RCCastFeedParser.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RCCastFeedParser : NSOperation


- (id)initWithFeedString:(NSString*)feedString;

@property (nonatomic, strong, readonly)  NSMutableArray *allCasts;


@end


