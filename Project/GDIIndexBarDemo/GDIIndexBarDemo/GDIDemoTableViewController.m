//
//  GDIDemoTableViewController.m
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GDIDemoTableViewController.h"

#define kReuseIdentifier @"reuseIdentifier"


@interface GDIDemoTableViewController ()

@end


@implementation GDIDemoTableViewController

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
    self.title = @"UITableViewController";
    self.indexBar = [[GDIIndexBar alloc] initWithTableView:self.tableView];
    self.indexBar.delegate = self;
    self.indexBar.textColor = [UIColor whiteColor];
    self.indexBar.textShadowColor = [UIColor colorWithWhite:0.f alpha:.5f];
    self.indexBar.textShadowOffset = UIOffsetMake(1, 1);
    self.indexBar.barBackgroundColor = [UIColor colorWithRed:0.f green:122.f/255.f blue:1.f alpha:1.f];
    self.indexBar.textSpacing = 5.f;
    self.indexBar.textFont = [UIFont fontWithName:@"Menlo-Bold" size:11.5f];
    [self.view addSubview:self.indexBar];
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
