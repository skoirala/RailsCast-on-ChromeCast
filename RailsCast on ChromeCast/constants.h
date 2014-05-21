typedef NS_ENUM(NSInteger, RCCastOperationStatus){
  RCCastOperationStatusExecuting,
  RCCastOperationStatusCancelled,
  RCCastOperationStatusFinished
};

extern NSString *const ChromeCastDeviceDidComeOnlineNotification;

extern NSString *const ChromeCastDeviceDidGoOfflineNotification;

extern NSString *const ChromeCastDeviceKey;

extern NSString *const RCCastPlayerViewReadyToPlayNotification;

#define RCCastManagerDidFinishDownloadingAndParsingNotification @"RCCastManagerDidFinishDownloadingAndParsingNotification"
