//
//  GDIDemoTableViewController.h
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <GDIIndexBar/GDIIndexBar.h>
#import "GDIMockDataModel.h"

@interface GDIDemoTableViewController : UITableViewController <GDIIndexBarDelegate>

/*!
 * Mock data source for the table view and index bar.
 */
@property (strong, nonatomic) GDIMockDataModel *dataModel;

/*!
 * Stores the index bar we are using for the table view.
 */
@property (strong, nonatomic) GDIIndexBar *indexBar;

@end
