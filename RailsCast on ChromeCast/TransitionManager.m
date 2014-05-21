//
//  TransitionManager.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "TransitionManager.h"

@implementation TransitionManager

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
  return 0.5;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{

  
  UIView* containerView = [transitionContext containerView];
  UIView *fromView = [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] view];
  UIView *toView = [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] view];
  UIView *mainContainer = [[UIView alloc] initWithFrame:toView.frame];
  mainContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
  [containerView addSubview:mainContainer];
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.imagePositionInNavigationView];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.image = self.image;
  [mainContainer addSubview:imageView];
  [containerView addSubview:toView];
  [containerView sendSubviewToBack:toView];
  
  
  CGRect finalFrame;
  if(self.reverse){
    CGRect originalFrame = self.imagePositionInNavigationView;
    originalFrame.origin.y = 64.0;
    imageView.frame = originalFrame;
    finalFrame = self.imagePositionInNavigationView;
    
  }else{
    
    finalFrame = imageView.frame;
    finalFrame.origin.y = 64;
    
  }
  
  
  

  NSTimeInterval duration = [self transitionDuration:transitionContext];

  
  [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    fromView.alpha = 0.0;
    imageView.frame = finalFrame;
  } completion:^(BOOL finished) {
    if ([transitionContext transitionWasCancelled]) {
      [mainContainer removeFromSuperview];
      fromView.alpha = 1.0;
    } else {
      [fromView removeFromSuperview];
      [mainContainer removeFromSuperview];
      fromView.alpha = 1.0;
    }
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
  }];
  

}

@end
