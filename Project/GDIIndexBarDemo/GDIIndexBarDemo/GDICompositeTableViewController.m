//
//  GDICompositeTableViewController.m
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GDICompositeTableViewController.h"

#define kReuseIdentifier @"reuseIdentifier"

@interface GDICompositeTableViewController ()

@end

@implementation GDICompositeTableViewController

#pragma mark - Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.dataModel = [[GDIMockDataModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"UIViewController";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
}


#pragma marka - Index bar delegate

- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    return self.dataModel.sectionNames.count;
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    return [self.dataModel.sectionNames objectAtIndex:index];
}

- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataModel.sectionNames objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataModel.sectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *letter = [self.dataModel.sectionNames objectAtIndex:section];
    NSArray *namesByLetter = [self.dataModel.data objectForKey:letter];
    return namesByLetter.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    NSString *letter = [self.dataModel.sectionNames objectAtIndex:indexPath.section];
    NSArray *namesByLetter = [self.dataModel.data objectForKey:letter];
    cell.textLabel.text = [namesByLetter objectAtIndex:indexPath.row];
    return cell;
}

@end
