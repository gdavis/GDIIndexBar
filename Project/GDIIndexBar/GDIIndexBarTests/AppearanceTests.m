//
//  AppearanceTests.m
//  GDIIndexBar
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GDIIndexBar/GDIIndexBar.h>

@interface AppearanceTests : XCTestCase {
    UITableView *_tableView;
}

@end

@implementation AppearanceTests

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

- (void)testAppearanceAlwaysShowBarBackgroundp
{
    [[GDIIndexBar appearance] setAlwaysShowBarBackground:@(YES)];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.alwaysShowBarBackground boolValue] == YES, @"Always show bar background boolean does not match value set by appearance protocol");
}

- (void)testAppearanceBarWidth
{
    CGFloat testWidth = 11.345f;
    [[GDIIndexBar appearance] setBarWidth:testWidth];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue(testWidth == indexBar.barWidth, @"Bar width does not match value set by appearance protocol");
}

- (void)testAppearanceBarBackgroundWidth
{
    CGFloat testWidth = 12.94f;
    [[GDIIndexBar appearance] setBarBackgroundWidth:testWidth];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue(testWidth == indexBar.barBackgroundWidth, @"Bar background width does not match value set by appearance protocol");
}

- (void)testAppearanceBarBackgroundOffset
{
    UIOffset offset = UIOffsetMake(2.5f, 5.75f);
    [[GDIIndexBar appearance] setBarBackgroundOffset:offset];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue(UIOffsetEqualToOffset(offset, indexBar.barBackgroundOffset), @"Bar background offset does not match value set by appearance protocol");
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

- (void)testApperanceTruncatedRowText
{
    [[GDIIndexBar appearance] setTruncatedRowText:@"-"];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    XCTAssertTrue([indexBar.truncatedRowText isEqualToString:@"-"], @"Truncated text does not match expected value set by appearance protocol");
}

@end
