//
//  MenuTableViewController.h
//  RailsCast on ChromeCast
//
//  Created by Sandeep on 16/05/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuTableViewControllerDelegate;

@interface MenuTableViewController : UITableViewController

@property (nonatomic, assign) id<MenuTableViewControllerDelegate> menuViewDelegate;

@end

@protocol MenuTableViewControllerDelegate <NSObject>

- (void)menuTableViewController:(MenuTableViewController*)viewController didSelectRowAtIndexPath:(NSIndexPath*)indexPath;

@end
