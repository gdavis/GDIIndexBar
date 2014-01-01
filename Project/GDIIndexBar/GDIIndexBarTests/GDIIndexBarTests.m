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