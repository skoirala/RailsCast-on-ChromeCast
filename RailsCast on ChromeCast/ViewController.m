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
#import "TransitionManager.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSIndexPath *clickedIndexPath;
@property (nonatomic, strong) RCCastManager *manager;
@property (nonatomic) BOOL filtered;

@end

@implementation ViewController

- (void)viewDidLoad
{
  
  [super viewDidLoad];
  self.navigationController.delegate = self;
  _manager = [RCCastManager manager];
  [_manager downloadFeed];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPullingFeeds:) name:RCCastManagerDidFinishDownloadingAndParsingNotification object:nil];
  
  
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
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cast.downloading = YES;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://railscasts.com/static/episodes/stills/%@", [[[cast.enclosureUrl lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
          cast.downloading = NO;
          cast.castImage = image;
          RCCastCollectionCell *cell = (RCCastCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
          cell.castImageView.image = image;
          
        });
      });
    }
  }
  return cell;
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


@end
