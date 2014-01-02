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


@interface GDIIndexBarMockDelegate : NSObject <GDIIndexBarDelegate>
@property (strong, nonatomic) NSArray *indexStrings;
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

- (void)testDelegateEqualToMockDelegate
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    GDIIndexBarMockDelegate *delegate = [[GDIIndexBarMockDelegate alloc] init];
    indexBar.delegate = delegate;
    XCTAssertNotNil(indexBar.delegate, @"Delegate should not be nil");
    XCTAssertEqual(indexBar.delegate, delegate, @"Delegate should be equal to the mock delegate");
}

- (void)testTopVerticalAlignment
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.verticalAlignment = GDIIndexBarAlignmentTop;
    XCTAssertEqual(indexBar.verticalAlignment, GDIIndexBarAlignmentTop, @"Vertical alignemnt does not equal top alignment.");
}

- (void)testCenterVerticalAlignment
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.verticalAlignment = GDIIndexBarAlignmentCenter;
    XCTAssertEqual(indexBar.verticalAlignment, GDIIndexBarAlignmentCenter, @"Vertical alignemnt does not equal center alignment.");
}

- (void)testBottomVerticalAlignment
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.verticalAlignment = GDIIndexBarAlignmentBottom;
    XCTAssertEqual(indexBar.verticalAlignment, GDIIndexBarAlignmentBottom, @"Vertical alignemnt does not equal bottom alignment.");
}

- (void)testAlwaysShowBarBackgroundProperty
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.alwaysShowBarBackground = @(YES);
    XCTAssertTrue([indexBar.alwaysShowBarBackground isEqualToNumber:@(YES)], @"Always show bar background property does not equal YES");
    indexBar.alwaysShowBarBackground = @(NO);
    XCTAssertTrue([indexBar.alwaysShowBarBackground isEqualToNumber:@(NO)], @"Always show bar background property does not equal NO");
}

@end


@implementation GDIIndexBarMockDelegate

- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    return self.indexStrings.count;
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    return [self.indexStrings objectAtIndex:index];
}

@end