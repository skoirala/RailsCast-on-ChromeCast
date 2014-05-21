//
//  RCCastFeedParser.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCastFeedParser.h"
#import "constants.h"
#import "RCCast.h"


#define kEntryElementTag @"item"


@interface RCCastFeedParser ()<NSXMLParserDelegate>

@property (nonatomic, copy) NSString *feedString;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong, readwrite) RCCast *currentCast;
@property (nonatomic, strong)  NSMutableArray *allCasts;
@property (nonatomic,assign) BOOL insideEntryTag;
@property (nonatomic, strong) NSString *currentElementName;
@property (nonatomic, assign) RCCastOperationStatus operationStatus;

@end

@implementation RCCastFeedParser

- (id)initWithFeedString:(NSString *)feedString{
  if(self = [super init]){
    _feedString = feedString;
  }
  return self;
}


- (void)main{
  _allCasts = [[NSMutableArray alloc] init];
  _parser = [[NSXMLParser alloc] initWithData:[_feedString dataUsingEncoding:NSUTF8StringEncoding]];
  [_parser setDelegate:self];
  [_parser parse];

  [self willChangeValueForKey:@"isExecuting"];
  _operationStatus = RCCastOperationStatusExecuting;
  [self didChangeValueForKey:@"isExecuting"];
  
}
//
//- (BOOL)isConcurrent{
//  return YES;
//}
//
//- (BOOL)isCancelled{
//  return _operationStatus == RCCastOperationStatusCancelled;
//}
//
//- (BOOL)isFinished{
//  return _operationStatus == RCCastOperationStatusFinished;
//}
//
//- (BOOL)isExecuting{
//  return _operationStatus != RCCastOperationStatusFinished  ||  _operationStatus != RCCastOperationStatusCancelled;
//}


- (void)parserDidStartDocument:(NSXMLParser *)parser{
  
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
  
  if([elementName isEqualToString:kEntryElementTag]){
    _currentCast = [[RCCast alloc] init];
    _insideEntryTag = YES;
  }
  
  
  if(_insideEntryTag){
    _currentElementName = elementName;
    [_currentCast extractAttributesFromAttributes:attributeDict forElementWithName:_currentElementName];
  }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
  
  if(_insideEntryTag){
    [_currentCast assignElement:_currentElementName withStringFound:string];
  }
  
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
  if([elementName isEqualToString:kEntryElementTag]){
    [_allCasts addObject:_currentCast];
    _insideEntryTag = NO;
  }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
   [_allCasts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"episodeNumber" ascending:YES]]];
//  [self willChangeValueForKey:@"isFinished"];
//  [self willChangeValueForKey:@"isExecuting"];
//  _operationStatus = RCCastOperationStatusFinished;
//  [self didChangeValueForKey:@"isFinished"];
//  [self didChangeValueForKey:@"isExecuting"];
  
}

@end
