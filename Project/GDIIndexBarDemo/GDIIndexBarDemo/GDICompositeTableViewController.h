//
//  GDICompositeTableViewController.h
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GDIIndexBar/GDIIndexBar.h>
#import "GDIMockDataModel.h"

@interface GDICompositeTableViewController : UIViewController <UITableViewDataSource, GDIIndexBarDelegate>

/*!
 * Mock data source for the table view and index bar.
 */
@property (strong, nonatomic) GDIMockDataModel *dataModel;

/*!
 * Reference to the UITableView from the storyboard.
 */
@property (strong, nonatomic) IBOutlet UITableView *tableView;

/*!
 * Stores the index bar we are using for the table view.
 */
@property (strong, nonatomic) IBOutlet GDIIndexBar *indexBar;


@end
