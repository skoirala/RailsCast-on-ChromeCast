//
//  RCCastDownloader.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "RCCastDownloader.h"
#import "constants.h"

static void *  kRCCastDownloaderContext = &kRCCastDownloaderContext;

#define URL_REQUEST_WITH_URL(url) \
 [NSURLRequest requestWithURL:url]

#define URL_WITH_STRING(string) \
  [NSURL URLWithString:string]

#define URL_REQUEST_WITH_STRING(string) \
 URL_REQUEST_WITH_URL(URL_WITH_STRING(string))



@interface RCCastDownloader ()<NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property (atomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) RCCastOperationStatus operationStatus;

@end

@implementation RCCastDownloader

- (id)init{
  if(self = [super init]){
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
  }
  return self;
}


- (void)start{
  NSURLRequest *request = URL_REQUEST_WITH_STRING(@"http://feeds2.feedburner.com/railscasts");
  NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
  [self willChangeValueForKey:@"isExecuting"];
  _operationStatus = RCCastOperationStatusExecuting;
  [self didChangeValueForKey:@"isExecuting"];
  [task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  if([keyPath isEqualToString:@"fractionCompleted"] && context == kRCCastDownloaderContext){
    NSLog(@"Completed %@", [change valueForKey:NSKeyValueChangeNewKey]);
  }else{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)cancel{
  @synchronized(self){
    [self willChangeValueForKey:@"isCanceled"];
    _operationStatus = RCCastOperationStatusCancelled;
    [self didChangeValueForKey:@"isCanceled"];
  }
}

- (BOOL)isCancelled{
  return _operationStatus == RCCastOperationStatusCancelled;
}

- (BOOL)isFinished{
  return _operationStatus == RCCastOperationStatusFinished;
}

- (BOOL)isExecuting{
  return _operationStatus != RCCastOperationStatusFinished || _operationStatus != RCCastOperationStatusCancelled;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
  NSError *error;
  
  if(_progress)
    [_progress removeObserver:self forKeyPath:@"fractionCompleted"];
  _responseString =  [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:&error];
  [self willChangeValueForKey:@"isFinished"];
  [self willChangeValueForKey:@"isExecuting"];
  _operationStatus = RCCastOperationStatusFinished;
  [self didChangeValueForKey:@"isFinished"];
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
  if(!_progress){
    _progress = [NSProgress progressWithTotalUnitCount:totalBytesExpectedToWrite];
    _progress.kind = NSProgressKindFile;
    [_progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:kRCCastDownloaderContext];
  }
  _progress.completedUnitCount = totalBytesWritten;
  
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
  
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
  
}


@end
