//
//  RCCastManager.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCastManager.h"
#import "RCCastDownloader.h"
#import "RCCastFeedParser.h"
#import "constants.h"



@interface RCCastManager()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong)   NSString  *feed;
@property (nonatomic, assign) RCCastFilterType previousFilter;

@end

@implementation RCCastManager

static void * kRCCastDownloaderContext = &kRCCastDownloaderContext;
static void * kRCCastFeedParserContext = &kRCCastFeedParserContext;

+ (instancetype)manager{
  static RCCastManager *manager ;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[RCCastManager alloc] init];
  });
  return manager;
}

- (id)init{
  if(self = [super init]){
    _queue = [[NSOperationQueue alloc] init];
    
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  if([keyPath isEqualToString:@"isFinished"] && context == kRCCastDownloaderContext){
    RCCastDownloader *downloader = (RCCastDownloader*)object;
    _feed = downloader.responseString;
    RCCastFeedParser *parser = [[RCCastFeedParser alloc] initWithFeedString:_feed];
    [parser addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:kRCCastFeedParserContext];
    [_queue addOperation:parser];
    _queue = nil;
  }else if([keyPath isEqualToString:@"isFinished"] && context == kRCCastFeedParserContext){
    if(!_queue){
      _queue = [[NSOperationQueue alloc] init];
    }
    RCCastFeedParser *parser = (RCCastFeedParser*)object;
    _railsCasts = parser.allCasts;
    [[NSNotificationCenter defaultCenter] postNotificationName:RCCastManagerDidFinishDownloadingAndParsingNotification object:self];
    
  }else{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)downloadFeed{
  _feed = [[NSMutableString alloc] init];
  RCCastDownloader *downloader = [[RCCastDownloader alloc] init];
  [downloader addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:kRCCastDownloaderContext];
  [_queue addOperation:downloader];
  
}

- (void)filterCastsWithFilterType:(RCCastFilterType)filterType{
  if(self.previousFilter == filterType) return;
  NSString *predicateFormat;
  switch (filterType) {
    case RCCastFilterNone:
      return;
      break;
      
    case RCCastFilterActiveRecord:
       predicateFormat = @"SELF.title contains[cd] 'active_record' or SELF.castDescription contains 'active_record' or SELF.title contains[cd] 'active record' or SELF.castDescription contains 'active record'";
      break;
      case RCCastFilterController:
       predicateFormat = @"SELF.title contains[cd] 'controller' or SELF.castDescription contains 'controller' or SELF.title contains[cd] 'controller' or SELF.castDescription contains 'controller'";
      break;
      case RCCastFilterRouting:
       predicateFormat = @"SELF.title contains[cd] 'router' or SELF.castDescription contains 'router' or SELF.title contains[cd] 'active routing' or SELF.castDescription contains 'routing'";
      break;
      case RCCastFilterView:
      predicateFormat = @"SELF.title contains[cd] 'view' or SELF.castDescription contains 'view'";
      break;
     default:
      break;
  };
  self.filteredCasts = [self.railsCasts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateFormat]];
}

- (NSString*)stringForParsing:(RCCastFeedParser *)feedParser{
  return _feed;
}

@end
