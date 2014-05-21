//
//  ViewController.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 14/05/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuTableViewController.h"

@interface ViewController : UIViewController <MenuTableViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end
