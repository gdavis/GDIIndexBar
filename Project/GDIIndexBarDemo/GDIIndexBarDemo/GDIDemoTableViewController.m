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

/*!
 * Stores the index bar we are using for the table view.
 */
@property (strong, nonatomic) GDIIndexBar *indexBar;

/*!
 * Stores an array of strings under a section name as the key
 */
@property (strong, nonatomic) NSMutableDictionary *data;

/*!
 * Stores the strings used to create sections and provides the string used by the index bar.
 */
@property (strong, nonatomic) NSMutableArray *sectionNames;

@end


@implementation GDIDemoTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createMockData];
    
    self.indexBar = [[GDIIndexBar alloc] initWithTableView:self.tableView];
    self.indexBar.delegate = self;
    [self.view addSubview:self.indexBar];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Mock Data

- (void)createMockData
{
    self.data = [NSMutableDictionary dictionary];
    self.sectionNames = [NSMutableArray array];
    
    NSArray *names = @[@"Liam",
                       @"Noah",
                       @"Oliver",
                       @"Adian",
                       @"Asher",
                       @"Owen",
                       @"Benjamin",
                       @"Declan",
                       @"Henry",
                       @"Jackson",
                       @"Ethan",
                       @"Charlotte",
                       @"Amelia",
                       @"Olivia",
                       @"Ava",
                       @"Aria",
                       @"Violet",
                       @"Sophia",
                       @"Scarlett",
                       @"Audrey",
                       @"Emma",
                       @"Nora",
                       @"Grace",
                       @"Lily",
                       @"Aurora",
                       @"Abigail",
                       @"Chloe",
                       @"Harper",
                       @"Alice",
                       @"Ella",
                       @"Claire",
                       @"Isabella",
                       @"Lucy",
                       ];
    
    // break the names into alphabetical groups
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        NSString *firstLetter = [name substringToIndex:1];
        NSMutableArray *namesByFirstLetter;
        
        if ([self.data objectForKey:firstLetter] == nil) {
            namesByFirstLetter = [NSMutableArray array];
            [self.data setObject:namesByFirstLetter forKey:firstLetter];
            [self.sectionNames addObject:firstLetter];
        }
        else {
            namesByFirstLetter = [self.data objectForKey:firstLetter];
        }
        
        [namesByFirstLetter addObject:name];
    }];
    
    // sort the groups
    NSArray *nameLists = [self.data allValues];
    [nameLists enumerateObjectsUsingBlock:^(NSMutableArray *namesByFirstLetter, NSUInteger idx, BOOL *stop) {
        [namesByFirstLetter sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
            return [name1 compare:name2];
        }];
    }];
    
    // sort the names
    [self.sectionNames sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
        return [name1 compare:name2];
    }];
    
    NSLog(@"Mock Data: %@", self.data);
}

#pragma marka - Index bar delegate

- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    return self.sectionNames.count;
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    return [self.sectionNames objectAtIndex:index];
}

- (CGFloat)widthForIndexBar:(GDIIndexBar *)indexBar
{
    return 20.f;
}

- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
{
    NSLog(@"did select section index: %i", index);
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *letter = [self.sectionNames objectAtIndex:section];
    NSArray *namesByLetter = [self.data objectForKey:letter];
    return namesByLetter.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    NSString *letter = [self.sectionNames objectAtIndex:indexPath.section];
    NSArray *namesByLetter = [self.data objectForKey:letter];
    cell.textLabel.text = [namesByLetter objectAtIndex:indexPath.row];
    return cell;
}

@end
