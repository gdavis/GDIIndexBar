//
//  GDIIndexBarTests.m
//  GDIIndexBarTests
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GDIIndexBar/GDIIndexBar.h>

@interface GDIIndexBarTests : XCTestCase {
    UITableView *_tableView;
}

@end

@implementation GDIIndexBarTests

- (void)setUp
{
    [super setUp];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
    _tableView = nil;
    [super tearDown];
}

- (void)testInitReturnsNotNil
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertNotNil(indexBar, @"Index bar must not be nil");
}

- (void)testTableViewEqualsExpectedTableView
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.tableView isEqual:_tableView], @"Table view must equal the view it was instantiated with.");
}

- (void)testAppearanceTextColor
{
    [[GDIIndexBar appearance] setTextColor:[UIColor redColor]];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.textColor isEqual:[UIColor redColor]], @"Text color does not match color set by appearance protocol");
}

- (void)testAppearanceTextShadowColor
{
    [[GDIIndexBar appearance] setTextShadowColor:[UIColor purpleColor]];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.textShadowColor isEqual:[UIColor purpleColor]], @"Text shadow color does not match color set by appearance protocol");
}

- (void)testAppearanceTextFont
{
    UIFont *font = [UIFont italicSystemFontOfSize:11.5];
    [[GDIIndexBar appearance] setTextFont:font];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.textFont isEqual:font], @"Text font does not match font set by appearance protocol");
}

- (void)testAppearanceBarBackgroundColor
{
    [[GDIIndexBar appearance] setBarBackgroundColor:[UIColor orangeColor]];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.barBackgroundColor isEqual:[UIColor orangeColor]], @"Bar background color does not match color set by appearance protocol");
}

@end
