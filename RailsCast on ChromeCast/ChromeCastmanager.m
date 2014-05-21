//
//  ChromeCastmanager.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 21/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <GoogleCast/GoogleCast.h>
#import "ChromeCastmanager.h"
#import "constants.h"
#import "RCCast.h"

@interface ChromeCastmanager ()<GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate>

@end

@implementation ChromeCastmanager{
  NSMutableArray *foundDevices;
  GCKDeviceScanner *scanner;
  GCKDevice *_currentDevice;
  GCKDeviceManager *deviceManager;
  GCKMediaControlChannel *mediaControlChannel;
  
}


- (void)pauseCast{
  if(mediaControlChannel){
    [mediaControlChannel pause];
  }
}

- (void)seekToTimeInterval:(NSTimeInterval)timeInterval{
  NSUInteger success =  [mediaControlChannel seekToTimeInterval:timeInterval];
  if(success == kGCKInvalidRequestID){
    NSLog(@"Invalid request %ld", (long)kGCKInvalidRequestID);
  }
}

+ (ChromeCastmanager*)sharedManager{
  static ChromeCastmanager *manager ;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    manager = [[ChromeCastmanager alloc] init];
  });
  return manager;
}

- (void)setCurrentDevice:(GCKDevice *)device{
  _currentDevice = device;
  if(device)
    [self connectToCurrentSelectedDevice];
}

- (GCKDevice*)currentDevice{
  return _currentDevice;
}


- (NSArray*)allDevices{
  return [foundDevices copy];
}

- (BOOL)isCurrentDevice:(GCKDevice *)device{
  return _currentDevice && [[_currentDevice deviceID] isEqualToString:[device deviceID]];
}

- (id)init{
  if(self = [super init]){
    foundDevices = [NSMutableArray array];
    scanner = [[GCKDeviceScanner alloc] init];
    
    mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    mediaControlChannel.delegate = self;
  }
  return self;
}

- (void)performScan{
  [scanner addListener:self];
  [scanner startScan];
}

- (void)playRCCast:(RCCast *)cast{
  
  GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
  
  [metadata setString:cast.title forKey:kGCKMetadataKeyTitle];
  
  
  
	[metadata setString:cast.description forKey:kGCKMetadataKeySubtitle];
  
  [metadata addImage:[[GCKImage alloc] initWithURL:cast.imageUrl width:200 height:100]];
  
  
  GCKMediaInformation *mediaInformation =
  [[GCKMediaInformation alloc] initWithContentID:cast.enclosureUrl
                                      streamType:GCKMediaStreamTypeNone
                                     contentType:@"video/mp4"
                                        metadata:metadata
                                  streamDuration:0
                                      customData:nil];
  
  [deviceManager addChannel:mediaControlChannel];
  if([mediaControlChannel requestStatus] != kGCKInvalidRequestID){
    [mediaControlChannel loadMedia:mediaInformation autoplay:YES playPosition:0];
  }
}

- (void)connectToCurrentSelectedDevice{
  NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
  deviceManager = [[GCKDeviceManager alloc] initWithDevice:_currentDevice clientPackageName:infoDict[@"CFBundleIdentifier"]];
  [deviceManager setDelegate:self];
  [deviceManager connect];
}

#pragma mark - GCKDeviceScannerListener methods

- (void)deviceDidComeOnline:(GCKDevice *)device{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceID = %@", device.deviceID];
  NSLog(@"device found %@", device.deviceID);
  if([[foundDevices filteredArrayUsingPredicate:predicate] count] == 0){
    [foundDevices addObject:device];
    NSNotification *notification = [NSNotification notificationWithName:ChromeCastDeviceDidComeOnlineNotification object:self userInfo:@{ChromeCastDeviceKey: device}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceID = %@", device.deviceID];
  NSArray *existingDevice = [foundDevices filteredArrayUsingPredicate:predicate];
  if([existingDevice count] > 0 ){
    GCKDevice *device = [foundDevices firstObject];
    NSUInteger index = [foundDevices indexOfObjectIdenticalTo:device];
    NSNotification *notification = [NSNotification notificationWithName:ChromeCastDeviceDidGoOfflineNotification object:self userInfo:@{ChromeCastDeviceKey: device}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [foundDevices removeObjectAtIndex:index];
  }
}



#pragma mark --- 


#pragma mark --- GCKDeviceManagerDelegate methods

/**
 * Called when a connection has been established to the device.
 *
 * @param deviceManager The device manager.
 */
NSString *const kReceiverAppId = @"5AEF9E81";

- (void)deviceManagerDidConnect:(GCKDeviceManager *)manager{
    [deviceManager launchApplication:kReceiverAppId];
}

/**
 * Called when the connection to the device has failed.
 *
 * @param deviceManager The device manager.
 * @param error The error that caused the connection to fail.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectWithError:(NSError *)error{
  NSLog(@"%@\n %@",NSStringFromSelector(_cmd), error);
}

/**
 * Called when the connection to the device has been terminated.
 *
 * @param deviceManager The device manager.
 * @param error The error that caused the disconnection; nil if there was no error (e.g. intentional
 * disconnection).
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didDisconnectWithError:(NSError *)error{
  NSLog(@"%@\n %@",NSStringFromSelector(_cmd), error);

}

#pragma mark Application connection callbacks

/**
 * Called when an application has been launched or joined.
 *
 * @param applicationMetadata Metadata about the application.
 * @param sessionID The session ID.
 * @param launchedApplication YES if the application was launched as part of the connection, or NO
 * if the application was already running and was joined.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication{
  
}

/**
 * Called when connecting to an application fails.
 *
 * @param deviceManager The device manager.
 * @param error The error that caused the failure.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error{
  NSLog(@"%@\n %@",NSStringFromSelector(_cmd), error);

}

/**
 * Called when disconnected from the current application.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didDisconnectFromApplicationWithError:(NSError *)error{
  NSLog(@"%@\n %@",NSStringFromSelector(_cmd), error);

}

/**
 * Called when a stop application request fails.
 *
 * @param deviceManager The device manager.
 * @param error The error that caused the failure.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToStopApplicationWithError:(NSError *)error{
  NSLog(@"%@\n %@",NSStringFromSelector(_cmd), error);

}

#pragma mark Device status callbacks

/**
 * Called whenever updated status information is received.
 *
 * @param applicationMetadata The application metadata.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata{

}

/**
 * Called whenever the volume changes.
 *
 * @param volumeLevel The current device volume level.
 * @param isMuted The current device mute state.
 */
- (void)deviceManager:(GCKDeviceManager *)deviceManager
volumeDidChangeToLevel:(float)volumeLevel
              isMuted:(BOOL)isMuted{
  
}

#pragma mark --- 

#pragma mark - GKMediaControlChanelDelegate

- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
didCompleteLoadWithSessionID:(NSInteger)sessionID{
  
}

/**
 * Called when a request to load media has failed.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
didFailToLoadMediaWithError:(NSError *)error{
  
}

/**
 * Called when updated player status information is received.
 */
- (void)mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel{
  
}

/**
 * Called when updated media metadata is received.
 */
- (void)mediaControlChannelDidUpdateMetadata:(GCKMediaControlChannel *)mediaControlChannel{
  NSLog(@"%f", [mediaControlChannel approximateStreamPosition]);
}

/**
 * Called when a request succeeds.
 *
 * @param requestID The request ID that failed. This is the ID returned when the request was made.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
   requestDidCompleteWithID:(NSInteger)requestID{
  
}

/**
 * Called when a request fails.
 *
 * @param requestID The request ID that failed. This is the ID returned when the request was made.
 * @param error The error. If any custom data was associated with the error, it will be in the
 * error's userInfo dictionary with the key {@code kGCKErrorCustomDataKey}.
 */
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
       requestDidFailWithID:(NSInteger)requestID
                      error:(NSError *)error{
  
}




@end
