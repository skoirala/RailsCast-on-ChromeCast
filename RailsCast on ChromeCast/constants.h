typedef NS_ENUM(NSInteger, RCCastOperationStatus){
  RCCastOperationStatusExecuting,
  RCCastOperationStatusCancelled,
  RCCastOperationStatusFinished
};

extern NSString *const kRCCastPlayerViewReadyToPlayNotification;
#define RCCastManagerDidFinishDownloadingAndParsingNotification @"RCCastManagerDidFinishDownloadingAndParsingNotification"
