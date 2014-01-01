//
//  GDIIndexBar.h
//  GDIIndexBar
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - GDIIndexBar

typedef enum {
    GDIIndexBarAlignmentTop,
    GDIIndexBarAlignmentCenter,
    GDIIndexBarAlignmentBottom
} GDIIndexBarAlignment;

@protocol GDIIndexBarDelegate;
@interface GDIIndexBar : UIControl

@property (nonatomic) GDIIndexBarAlignment verticalAlignment;
@property (weak, nonatomic) IBOutlet id <GDIIndexBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *barBackgroundView;

/*!
 * If YES, always displays the background bar. If NO, the bar background view is only displayed when a user taps on the index bar.
 * @discussion Defaults to YES for iOS7 devices, and NO for iOS6.
 */
@property (nonatomic) BOOL alwaysShowBarBackground;

/*!
 * Property is used for determining the width of the hit area for the control.
 * @discussion This value must be greater than or equal to the `barBackgroundWidth` value. Default value is 44. 
 */
@property (nonatomic) CGFloat barWidth;

/*!
 * Property used to determine the width of the bar background view. 
 * @discussion This value should be less than or equal to the `barWidth` value. This value is applied to the background view position.
 */
@property (nonatomic) CGFloat barBackgroundWidth;
@property (nonatomic) UIOffset barBackgroundOffset;

@property (nonatomic) CGFloat textSpacing;
@property (nonatomic) UIOffset textShadowOffset;

@property (strong, nonatomic) UIColor *textColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *textShadowColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *textFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *barBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

/*!
 * Offsets the position of the text drawing.
 */
@property (nonatomic) UIOffset textOffset;

/*!
 * Initializes the index bar with an associated table view.
 */
- (id)initWithTableView:(UITableView *)tableView;

/*!
 * Reloads the index bar by asking the delegate for new display information.
 */
- (void)reload;

/*!
 * Defines the rectangle the GDIIndexBar will set as its frame when `layoutSubviews` is called.
 * @discussion This method is not intended to be called directly. Instead, it is meant to be overridden by subclasses to provide a new frame for the `GDIIndexBar`.
 */
- (CGRect)rectForIndexBarFrame;

/*!
 * Defines the frame for the text within the GDIIndexBar's bounds.
 * @discussion This method is not intended to be called directly. Instead, it is meant to be overridden by subclasses to provide a new frame for the text area.
 */
- (CGRect)rectForTextArea;

/*!
 * Defines the frame for the bar background view within the GDIIndexBar's bounds. Available for override.
 * @discussion This method is not intended to be called directly. Instead, it is meant to be overridden by subclasses to provide a new frame for the bar background view.
 */
- (CGRect)rectForBarBackgroundView;

@end


#pragma mark - GDIIndexBarDelegate

/*!
 * Defines the behavior of the index bar.
 */
@protocol GDIIndexBarDelegate <NSObject>

@required

/*!
 * Asks the delegate for the number of indexes to display in the index bar.
 */
- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar;

/*!
 * Asks the delegate for the string to display at the given index.
 */
- (NSString *)stringForIndex:(NSUInteger)index;

@optional

/*!
 * Informs the delegate the user has touched the index bar at the specified index.
 */
- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index;

@end