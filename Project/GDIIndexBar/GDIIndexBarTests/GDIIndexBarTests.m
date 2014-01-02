//
//  GDIIndexBarTests.m
//  GDIIndexBarTests
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GDIIndexBar/GDIIndexBar.h>

#define kTableRect CGRectMake(0, 64.f, 320.f, 468.f)

@interface GDIIndexBarTests : XCTestCase {
    UIView *_containerView;
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
    _containerView = [[UIView alloc] initWithFrame:kTableRect];
    _tableView = [[UITableView alloc] initWithFrame:kTableRect];
    [_containerView addSubview:_tableView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_containerView];
}

- (void)tearDown
{
    _containerView = nil;
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

- (void)testVerticalAlignment
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.verticalAlignment = GDIIndexBarAlignmentTop;
    XCTAssertEqual(indexBar.verticalAlignment, GDIIndexBarAlignmentTop, @"Vertical alignemnt does not equal top alignment.");
    indexBar.verticalAlignment = GDIIndexBarAlignmentCenter;
    XCTAssertEqual(indexBar.verticalAlignment, GDIIndexBarAlignmentCenter, @"Vertical alignemnt does not equal center alignment.");
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

- (void)testTextFont
{
    UIFont *font = [UIFont fontWithName:@"Futura-Medium" size:10.25f];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.textFont = font;
    XCTAssertTrue([font isEqual:indexBar.textFont], @"textFont does not match the expected font.");
}

- (void)testTextColor
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.textColor = [UIColor orangeColor];
    XCTAssertTrue([indexBar.textColor isEqual:[UIColor orangeColor]], @"textColor does not match the expected color.");
}

- (void)testTextSpacing
{
    CGFloat spacing = 17.23f;
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.textSpacing = spacing;
    XCTAssertTrue(spacing == indexBar.textSpacing, @"textSpacing does not match the expected value.");
}

- (void)testTextShadowColor
{
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.textShadowColor = [UIColor orangeColor];
    XCTAssertTrue([indexBar.textShadowColor isEqual:[UIColor orangeColor]], @"textShadowColor does not match the expected color.");
}

- (void)testTextShadowOffset
{
    UIOffset offset = UIOffsetMake(129.34, 34.3);
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.textShadowOffset = offset;
    XCTAssertTrue(UIOffsetEqualToOffset(offset, indexBar.textShadowOffset), @"textShadowOffset does not match the expected offset.");
}

- (void)testBarBackgroundWidth
{
    CGFloat width = 28.12;
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.barBackgroundWidth = width;
    XCTAssertTrue(width == indexBar.barBackgroundWidth, @"barBackgroundWidth does not match the expected value.");
}

- (void)testBarBackgroundColor
{
    UIColor *color = [UIColor yellowColor];
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.barBackgroundColor = color;
    XCTAssertTrue([color isEqual:indexBar.barBackgroundColor], @"barBackgroundColor does not match the expected color.");
}

- (void)testBarBackgroundOffset
{
    UIOffset offset = UIOffsetMake(129.34, 34.3);
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.barBackgroundOffset = offset;
    XCTAssertTrue(UIOffsetEqualToOffset(offset, indexBar.barBackgroundOffset), @"barBackgroundOffset does not match the expected offset.");
}

- (void)testBarBackgroundCornerRadius
{
    CGFloat width = 12.39;
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    indexBar.barBackgroundCornerRadius = width;
    XCTAssertTrue(width == indexBar.barBackgroundCornerRadius, @"barBackgroundCornerRadius does not match the expected value.");
}

- (void)testIndexBarPositionsOnTheRightSideOfTheTableView
{
    CGFloat barWidth = [[GDIIndexBar appearance] barWidth];
    CGRect expectedRect = CGRectMake(_tableView.frame.size.width - barWidth,
                                     _tableView.frame.origin.y,
                                     barWidth,
                                     _tableView.frame.size.height);
    GDIIndexBar *indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    GDIIndexBarMockDelegate *delegate = [[GDIIndexBarMockDelegate alloc] init];
    indexBar.delegate = delegate;
    [_containerView addSubview:indexBar];
    [_containerView layoutIfNeeded]; // force layout
    XCTAssertTrue(CGRectEqualToRect(expectedRect, indexBar.frame), @"index bar frame %@ does not match expected rect: %@.",
                  NSStringFromCGRect(indexBar.frame),
                  NSStringFromCGRect(expectedRect));
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