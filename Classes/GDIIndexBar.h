//
//  GDIIndexBar.h
//  GDIIndexBar
//
//  TODO: Finish Documentation
//  TODO: Rework offsets for text and bar background.
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - GDIIndexBar

typedef enum {
    GDIIndexBarAlignmentCenter = 0,
    GDIIndexBarAlignmentTop,
    GDIIndexBarAlignmentBottom
} GDIIndexBarAlignment;

@protocol GDIIndexBarDelegate;

/*!
 *
 */
@interface GDIIndexBar : UIControl

/*!
 *
 */
@property (weak, nonatomic) IBOutlet id <GDIIndexBarDelegate> delegate;

/*!
 *
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/*!
 *
 */
@property (strong, nonatomic) IBOutlet UIView *barBackgroundView;

/*!
 * @abstract String to display between index bar rows when the displayed list of indexes is truncated in order to fit the table view.
 * @discussion GDIIndex bar is built to display truncated text when the index bar resizes and there is not enough vertical space to fit all indexes provided. When this happens, rows omitted in the display are replaced with the truncatedRowText value. Defaults to "•".
 */
@property (strong, nonatomic) NSString *truncatedRowText UI_APPEARANCE_SELECTOR;

/*!
 * Property to determine the verical position of the text displayed in the index bar. Defaults to `GDIIndexBarAlignmentTop`.
 */
@property (nonatomic) GDIIndexBarAlignment verticalAlignment UI_APPEARANCE_SELECTOR;

/*!
 * If YES, always displays the background bar. If NO, the bar background view is only displayed when a user taps on the index bar. This value uses an NSNumber instead of BOOL to conform to the UIAppearance protocol.
 * @discussion Defaults to YES for iOS7 devices, and NO for iOS6.
 */
@property (strong, nonatomic) NSNumber *alwaysShowBarBackground UI_APPEARANCE_SELECTOR;

/*!
 * Property is used for determining the width of the hit area for the control.
 * @discussion This value must be greater than or equal to the `barBackgroundWidth` value. Default value is 44.
 */
@property (assign, nonatomic) CGFloat barWidth UI_APPEARANCE_SELECTOR;

/*!
 * Property used to determine the width of the bar background view. 
 * @discussion This value should be less than or equal to the `barWidth` value. This value is applied to the background view position.
 */
@property (assign, nonatomic) CGFloat barBackgroundWidth UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (strong, nonatomic) UIColor *barBackgroundColor UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (assign, nonatomic) UIOffset barBackgroundOffset UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (assign, nonatomic) CGFloat barBackgroundCornerRadius UI_APPEARANCE_SELECTOR;

/*!
 * Offsets the position of the text drawing.
 */
@property (nonatomic) UIOffset textOffset UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (strong, nonatomic) UIFont *textFont UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (strong, nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (assign, nonatomic) CGFloat textSpacing UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (strong, nonatomic) UIColor *textShadowColor UI_APPEARANCE_SELECTOR;

/*!
 *
 */
@property (assign, nonatomic) UIOffset textShadowOffset UI_APPEARANCE_SELECTOR;


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