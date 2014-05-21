//
//  TransitionManager.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitionManager : NSObject<UIViewControllerAnimatedTransitioning>

@property(nonatomic, assign) CGRect imagePositionInNavigationView;
@property (nonatomic, assign) UIImage *image;
@property (nonatomic, assign) BOOL reverse;

@end
