//
//  RCCastCollectionViewLayoutAttribute.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCastCollectionViewLayoutAttribute.h"

@implementation RCCastCollectionViewLayoutAttribute

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
  UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
  [self modifyLayoutAttribute:layoutAttributes];
  
  return layoutAttributes;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
  NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
  for(UICollectionViewLayoutAttributes *attribute in layoutAttributes){
    [self modifyLayoutAttribute:attribute];
  }
  return layoutAttributes;
}

- (void)modifyLayoutAttribute:(UICollectionViewLayoutAttributes*)attributes{

  
}

@end
