//
//  ViewController.m
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "RCCastManager.h"
#import "RCCastCollectionCell.h"
#import "constants.h"
#import "RCCast.h"
#import "VideoViewController.h"
#import "NVSlideMenuController.h"
#import <GoogleCast/GoogleCast.h>
#import "TransitionManager.h"
#import "ChromeCastmanager.h"

typedef void(^SetImage)(NSIndexPath*, UIImage*);

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSIndexPath *clickedIndexPath;
@property (nonatomic, strong) RCCastManager *manager;
@property (nonatomic) BOOL filtered;
@property (nonatomic, weak) UIButton *chromeCastButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
  
  [super viewDidLoad];
  self.navigationController.delegate = self;
  _manager = [RCCastManager manager];
  [_manager downloadFeed];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPullingFeeds:) name:RCCastManagerDidFinishDownloadingAndParsingNotification object:nil];
  [[ChromeCastmanager sharedManager] performScan];
  [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(deviceDidComeOnline:) name:ChromeCastDeviceDidComeOnlineNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidGoOffline:) name:ChromeCastDeviceDidGoOfflineNotification object:nil];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button addTarget:self action:@selector(chromeCastButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [button setEnabled:NO];
  button.frame = CGRectMake(0, 0 , 30, 30);
  [button setBackgroundImage:[UIImage imageNamed:@"cast_off.png"] forState:UIControlStateNormal];
  _chromeCastButton = button;
  UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
  [self.navigationItem setRightBarButtonItem:rightButtonItem];
}

- (void)chromeCastButtonTapped:(UIButton*)button{
  
  GCKDevice *currentDevice = [[ChromeCastmanager sharedManager] currentDevice];
  NSString *title;
  if(!currentDevice)
    title = @"\u2713 Default";
  else
    title = @"Default";
  
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select device" delegate:self cancelButtonTitle:title destructiveButtonTitle:nil otherButtonTitles:nil, nil];
  NSArray *devices = [[ChromeCastmanager sharedManager] allDevices];
  
  for(GCKDevice *aDevice in devices){
    NSString *additionalTitle;
    if([[ChromeCastmanager sharedManager] isCurrentDevice:aDevice]){
      additionalTitle = [NSString stringWithFormat:@"\u2713 %@", [aDevice friendlyName]];

    }else{
      additionalTitle = [aDevice friendlyName];
    }
    [actionSheet addButtonWithTitle:additionalTitle];
  }
  
  
  [actionSheet showInView:self.view];
}

- (void)deviceDidComeOnline:(NSNotification*)note{
  UIImage *image;
  if([[[ChromeCastmanager sharedManager] allDevices] count] > 0){
    image = [UIImage imageNamed:@"cast_on.png"];
    [_chromeCastButton setEnabled:YES];
  }else{
    image = [UIImage imageNamed:@"cast_off.png"];
    [_chromeCastButton setEnabled:NO];
  }
  [_chromeCastButton setBackgroundImage:image forState:UIControlStateNormal];
  
}

- (void)deviceDidGoOffline:(NSNotification*)note{
  UIImage *image;
  if([[[ChromeCastmanager sharedManager] allDevices] count] > 0){
    image = [UIImage imageNamed:@"cast_on.png"];
    [_chromeCastButton setEnabled:YES];
  }else{
    [_chromeCastButton setEnabled:NO];
    image = [UIImage imageNamed:@"cast_off.png"];
  }
  [_chromeCastButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)finishedPullingFeeds:(NSNotification*)note{
  if(![NSThread isMainThread]){
    [self performSelector:@selector(finishedPullingFeeds:) onThread:[NSThread mainThread] withObject:note waitUntilDone:NO];
    return;
  }
  [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  if(!self.filtered)
    return [[_manager railsCasts] count];
  else
    return [[_manager filteredCasts] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  RCCastCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RCCollectionViewCell" forIndexPath:indexPath];
  RCCast *cast;
  if(!self.filtered)
    cast = [[_manager railsCasts] objectAtIndex:indexPath.item];
  else
    cast = [[_manager filteredCasts] objectAtIndex:indexPath.item];
  
  [cell setCast:cast];
  cell.layer.shouldRasterize = YES;
  cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
  
  if(cast.castImage){
    cell.castImageView.image = cast.castImage;
  }else{
    if(!cast.downloading){
      [self downloadImageForRowAtIndexPath:indexPath forCast:cast];
    }
  }
  return cell;
}

- (void)downloadImageForRowAtIndexPath:(NSIndexPath*)indexPath forCast:(RCCast*)cast{
  __weak ViewController *weakSelf = self;
  SetImage setImage = ^(NSIndexPath *indexPath, UIImage *image){
    dispatch_async(dispatch_get_main_queue(), ^{
      cast.downloading = NO;
      cast.castImage = image;
      RCCastCollectionCell *cell = (RCCastCollectionCell*)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
      cell.castImageView.image = image;
    });
  };
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    cast.downloading = YES;
    NSURL *url = cast.imageUrl;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    setImage(indexPath, image);
  });
}


- (void)menuTableViewController:(MenuTableViewController *)viewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  NVSlideMenuController *slideMenu = [self slideMenuController];
  [slideMenu closeMenuAnimated:YES completion:^(BOOL completion){
    if(indexPath.row == 0){
      if(!self.filtered) return;
      self.filtered = NO;
      [self.collectionView reloadData];
    }else if(indexPath.row == 1){
      [self.manager filterCastsWithFilterType:RCCastFilterActiveRecord];
      self.filtered = YES;
      [self.collectionView reloadData];
    }else if(indexPath.row == 2){
      
      [self.manager filterCastsWithFilterType:RCCastFilterRouting];
      self.filtered = YES;
      [self.collectionView reloadData];
    }else if(indexPath.row == 3){
      [self.manager filterCastsWithFilterType:RCCastFilterController];
      self.filtered = YES;
      [self.collectionView reloadData];
    }else if(indexPath.row == 4){
      [self.manager filterCastsWithFilterType:RCCastFilterView];
      self.filtered = YES;
      [self.collectionView reloadData];
    }
  }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if([segue.identifier isEqualToString:@"VideoViewControllerSegue"]){
    VideoViewController *viewController = (VideoViewController*)segue.destinationViewController;
    self.clickedIndexPath = [self.collectionView indexPathForCell:sender];
    RCCast *cast;
    if(self.filtered){
      cast = [[self.manager filteredCasts] objectAtIndex:self.clickedIndexPath.item];
    }else{
      cast = [[self.manager railsCasts] objectAtIndex:self.clickedIndexPath.item];
    }
    viewController.castToPlay = cast;
  }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
  RCCastCollectionCell *cell = (RCCastCollectionCell*)[self.collectionView cellForItemAtIndexPath:self.clickedIndexPath];
  CGRect imageFrame = [cell convertRect:cell.castImageView.frame toView:self.collectionView];
  imageFrame = [self.collectionView convertRect:imageFrame toView:self.navigationController.view];
  TransitionManager *manager = [[TransitionManager alloc] init];
  manager.imagePositionInNavigationView = imageFrame;
  manager.image = cell.castImageView.image;
  if(operation == UINavigationControllerOperationPush){
    VideoViewController *videoViewController = (VideoViewController*)toVC;
    videoViewController.imageFrame = imageFrame;
    videoViewController.originalImage = manager.image;
    manager.reverse = NO;
  }else{
    VideoViewController *videoViewController = (VideoViewController*)fromVC;
    manager.imagePositionInNavigationView = videoViewController.imageFrame;
    manager.reverse = YES;

  }
  return manager; 
}


#pragma mark --- 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  if(buttonIndex == 0){
    [[ChromeCastmanager sharedManager] setCurrentDevice:nil];
  }else{
    GCKDevice *selectedDevice = [[[ChromeCastmanager sharedManager] allDevices] objectAtIndex:buttonIndex - 1];
    [[ChromeCastmanager sharedManager] setCurrentDevice:selectedDevice];
  }
}


@end
