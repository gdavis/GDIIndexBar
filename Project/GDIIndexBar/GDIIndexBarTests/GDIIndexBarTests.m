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

@interface GDIIndexBarMockDelegate : NSObject <GDIIndexBarDelegate>
@property (strong, nonatomic) NSArray *indexStrings;
@end


@interface GDIIndexBarTests : XCTestCase {
    UIView *_containerView;
    UITableView *_tableView;
    GDIIndexBar *_indexBar;
    GDIIndexBarMockDelegate *_delegate;
}

@end

@implementation GDIIndexBarTests

- (void)setUp
{
    [super setUp];
    _containerView = [[UIView alloc] initWithFrame:kTableRect];
    _tableView = [[UITableView alloc] initWithFrame:kTableRect];
    
    _indexBar = [[GDIIndexBar alloc] initWithTableView:_tableView];
    _delegate = [[GDIIndexBarMockDelegate alloc] init];
    _indexBar.delegate = _delegate;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_containerView];
    [_containerView addSubview:_tableView];
    [_containerView addSubview:_indexBar];
    [_containerView layoutIfNeeded];
}

- (void)tearDown
{
    _delegate = nil;
    _indexBar = nil;
    _containerView = nil;
    _tableView = nil;
    [super tearDown];
}

- (void)testInitReturnsNotNil
{
    XCTAssertNotNil(_indexBar, @"Index bar must not be nil");
}

- (void)testTableViewEqualsExpectedTableView
{
    XCTAssertTrue([_indexBar.tableView isEqual:_tableView], @"Table view must equal the view it was instantiated with.");
}

- (void)testDelegateEqualToMockDelegate
{
    XCTAssertNotNil(_indexBar.delegate, @"Delegate should not be nil");
    XCTAssertEqual(_indexBar.delegate, _delegate, @"Delegate should be equal to the mock delegate");
}

- (void)testVerticalAlignment
{
    _indexBar.verticalAlignment = GDIIndexBarAlignmentTop;
    XCTAssertEqual(_indexBar.verticalAlignment, GDIIndexBarAlignmentTop, @"Vertical alignemnt does not equal top alignment.");
    _indexBar.verticalAlignment = GDIIndexBarAlignmentCenter;
    XCTAssertEqual(_indexBar.verticalAlignment, GDIIndexBarAlignmentCenter, @"Vertical alignemnt does not equal center alignment.");
    _indexBar.verticalAlignment = GDIIndexBarAlignmentBottom;
    XCTAssertEqual(_indexBar.verticalAlignment, GDIIndexBarAlignmentBottom, @"Vertical alignemnt does not equal bottom alignment.");
}

- (void)testAlwaysShowBarBackgroundProperty
{
    _indexBar.alwaysShowBarBackground = @(YES);
    XCTAssertTrue([_indexBar.alwaysShowBarBackground isEqualToNumber:@(YES)], @"Always show bar background property does not equal YES");
    _indexBar.alwaysShowBarBackground = @(NO);
    XCTAssertTrue([_indexBar.alwaysShowBarBackground isEqualToNumber:@(NO)], @"Always show bar background property does not equal NO");
}

- (void)testTextFont
{
    UIFont *font = [UIFont fontWithName:@"Futura-Medium" size:10.25f];
    _indexBar.textFont = font;
    XCTAssertTrue([font isEqual:_indexBar.textFont], @"textFont does not match the expected font.");
}

- (void)testTextColor
{
    _indexBar.textColor = [UIColor orangeColor];
    XCTAssertTrue([_indexBar.textColor isEqual:[UIColor orangeColor]], @"textColor does not match the expected color.");
}

- (void)testTextSpacing
{
    CGFloat spacing = 17.23f;
    _indexBar.textSpacing = spacing;
    XCTAssertTrue(spacing == _indexBar.textSpacing, @"textSpacing does not match the expected value.");
}

- (void)testTextShadowColor
{
    _indexBar.textShadowColor = [UIColor orangeColor];
    XCTAssertTrue([_indexBar.textShadowColor isEqual:[UIColor orangeColor]], @"textShadowColor does not match the expected color.");
}

- (void)testTextShadowOffset
{
    UIOffset offset = UIOffsetMake(129.34, 34.3);
    _indexBar.textShadowOffset = offset;
    XCTAssertTrue(UIOffsetEqualToOffset(offset, _indexBar.textShadowOffset), @"textShadowOffset does not match the expected offset.");
}

- (void)testBarBackgroundWidth
{
    CGFloat width = 28.12;
    _indexBar.barBackgroundWidth = width;
    XCTAssertTrue(width == _indexBar.barBackgroundWidth, @"barBackgroundWidth does not match the expected value.");
}

- (void)testBarBackgroundColor
{
    UIColor *color = [UIColor yellowColor];
    _indexBar.barBackgroundColor = color;
    XCTAssertTrue([color isEqual:_indexBar.barBackgroundColor], @"barBackgroundColor does not match the expected color.");
}

- (void)testBarBackgroundOffset
{
    UIOffset offset = UIOffsetMake(129.34, 34.3);
    _indexBar.barBackgroundOffset = offset;
    XCTAssertTrue(UIOffsetEqualToOffset(offset, _indexBar.barBackgroundOffset), @"barBackgroundOffset does not match the expected offset.");
}

- (void)testBarBackgroundCornerRadius
{
    CGFloat width = 12.39;
    _indexBar.barBackgroundCornerRadius = width;
    XCTAssertTrue(width == _indexBar.barBackgroundCornerRadius, @"barBackgroundCornerRadius does not match the expected value.");
}

- (void)testIndexBarPositionsOnTheRightSideOfTheTableView
{
    CGFloat barWidth = [[GDIIndexBar appearance] barWidth];
    CGRect expectedRect = CGRectMake(_tableView.frame.origin.x + _tableView.frame.size.width - barWidth,
                                     _tableView.frame.origin.y,
                                     barWidth,
                                     _tableView.frame.size.height);
    XCTAssertTrue(CGRectEqualToRect(expectedRect, _indexBar.frame), @"index bar frame %@ does not match expected rect: %@.",
                  NSStringFromCGRect(_indexBar.frame),
                  NSStringFromCGRect(expectedRect));
}

- (void)testRectForTextAreaWithCenterAlignment
{
    _indexBar.verticalAlignment = GDIIndexBarAlignmentCenter;
    [_indexBar layoutIfNeeded]; // force layout
    
    CGFloat barWidth = [[GDIIndexBar appearance] barWidth];
    UIFont *font = [[GDIIndexBar appearance] textFont];
    CGFloat lineHeight = [@"0" sizeWithFont:font].height + _indexBar.textSpacing;
    CGFloat heightOfTexts = [_delegate numberOfIndexesForIndexBar:_indexBar] * lineHeight;
    CGFloat height = heightOfTexts + _indexBar.textSpacing * 2;
    CGFloat yp = _tableView.frame.size.height * .5 - height * .5;
    CGRect expectedRect = CGRectMake(0,
                                     yp,
                                     barWidth,
                                     height);
    CGRect textRect = [_indexBar rectForTextArea];
    XCTAssertTrue(CGRectEqualToRect(expectedRect, textRect), @"text rect %@ does not match expected rect: %@.",
                  NSStringFromCGRect(textRect),
                  NSStringFromCGRect(expectedRect));
}

- (void)testRectForTextAreaWithTopAlignment
{
    _indexBar.verticalAlignment = GDIIndexBarAlignmentTop;
    [_indexBar layoutIfNeeded]; // force layout
    
    CGFloat barWidth = [[GDIIndexBar appearance] barWidth];
    UIFont *font = [[GDIIndexBar appearance] textFont];
    CGFloat lineHeight = [@"0" sizeWithFont:font].height + _indexBar.textSpacing;
    CGFloat heightOfTexts = [_delegate numberOfIndexesForIndexBar:_indexBar] * lineHeight;
    CGFloat height = heightOfTexts + _indexBar.textSpacing * 2;
    CGFloat yp = 0;
    CGRect expectedRect = CGRectMake(0,
                                     yp,
                                     barWidth,
                                     height);
    CGRect textRect = [_indexBar rectForTextArea];
    XCTAssertTrue(CGRectEqualToRect(expectedRect, textRect), @"text rect %@ does not match expected rect: %@.",
                  NSStringFromCGRect(textRect),
                  NSStringFromCGRect(expectedRect));
}

- (void)testRectForTextAreaWithBottomAlignment
{
    _indexBar.verticalAlignment = GDIIndexBarAlignmentBottom;
    [_indexBar layoutIfNeeded]; // force layout
    
    CGFloat barWidth = [[GDIIndexBar appearance] barWidth];
    UIFont *font = [[GDIIndexBar appearance] textFont];
    CGFloat lineHeight = [@"0" sizeWithFont:font].height + _indexBar.textSpacing;
    CGFloat heightOfTexts = [_delegate numberOfIndexesForIndexBar:_indexBar] * lineHeight;
    CGFloat height = heightOfTexts + _indexBar.textSpacing * 2;
    CGFloat yp = _tableView.frame.size.height - height;
    CGRect expectedRect = CGRectMake(0,
                                     yp,
                                     barWidth,
                                     height);
    CGRect textRect = [_indexBar rectForTextArea];
    XCTAssertTrue(CGRectEqualToRect(expectedRect, textRect), @"text rect %@ does not match expected rect: %@.",
                  NSStringFromCGRect(textRect),
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