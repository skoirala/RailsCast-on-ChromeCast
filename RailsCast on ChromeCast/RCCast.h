//
//  RCCast.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCast : NSObject


- (void) assignElement:(NSString*)elementName withStringFound:(NSString*)string;
- (void) extractAttributesFromAttributes:(NSDictionary*)attributeDict forElementWithName:(NSString*)elementName;

@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, strong) UIImage *castImage;



@property (nonatomic, assign) NSInteger episodeNumber;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *castDescription;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *enclosureUrl;
@property (nonatomic, copy) NSString *enclosureLength;
@property (nonatomic, copy) NSString *enclosureType;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *duration;


@end
