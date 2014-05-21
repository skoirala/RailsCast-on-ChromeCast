//
//  RCCast.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCast.h"

#define kTitleTag @"title"
#define kDescriptionTag @"description"
#define kPubDateTag @"pubDate"
#define kEnclosureTag @"enclosure"
#define kLinkTag @"link"
#define kAuthorTag @"itunes:author"
#define kSubtitleTag @"itunes:subtitle"
#define kSummaryTag @"itunes:summary"
#define kDurationTag @"itunes:duration"


@implementation RCCast

- (void)assignElement:(NSString*)elementName withStringFound:(NSString*)string{
  if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) return;
  if([elementName isEqualToString:kTitleTag] ){
    self.title = string;
  }
  
  if([elementName isEqualToString:kDescriptionTag]){
    self.castDescription = string;
  }
  
  if([elementName isEqualToString:kPubDateTag]){
    self.pubDate = string;
  }
  
  if([elementName isEqualToString:kLinkTag]){
    self.link = string;
  }
  
  if([elementName isEqualToString:kAuthorTag]){
    self.author = string;
  }
  
  if([elementName isEqualToString:kSubtitleTag]){
    self.subtitle = string;
  }
  
  if([elementName isEqualToString:kSummaryTag]){
    self.summary = string;
  }
  
  if([elementName isEqualToString:kDurationTag]){
    self.duration = string;
  }

}

- (void)extractAttributesFromAttributes:(NSDictionary *)attributeDict forElementWithName:(NSString *)elementName{
  if([elementName isEqualToString:kEnclosureTag]){
    self.enclosureUrl = attributeDict[@"url"];
    self.enclosureLength = attributeDict[@"length"];
    self.enclosureType = attributeDict[@"type"];
    [self setEpisode];
  }
}

- (void)setEpisode{
  NSError *error;
  NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"(\\d+)" options:0 error:&error];
  if(error){
    NSLog(@"error %@", error);
    return;
  }
  
  NSTextCheckingResult  *result =  [expression firstMatchInString:self.enclosureUrl options:0 range:NSMakeRange(0, self.enclosureUrl.length)];
  self.episodeNumber = [[self.enclosureUrl substringWithRange:result.range] integerValue];
  NSLog(@"%d", self.episodeNumber);

}

- (NSString*)description{
  return [NSString stringWithFormat:@"title: %@  Url: %@ ", self.title, self.enclosureUrl];
}

@end
