//
//  GDIIndexBar.h
//  GDIIndexBar
//
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
 * TODO: Finish class description
 */
@interface GDIIndexBar : UIControl

/*!
 * @abstract The delegate of the index bar object.
 * @discussion The delegate of the index bar provides the number of indexes and the text to display for each index. The delegate also responds to index bar touch events in order to update the scroll position of the content for the index bar.
 */
@property (weak, nonatomic) IBOutlet id <GDIIndexBarDelegate> delegate;

/*!
 * @abstract The table view for the index bar object.
 * @discussion Reference to the table view the index bar is scrolling. Allows the index bar to appropriately size and position the index bar relative to the provided table view.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/*!
 * @abstract The background view for the index bar.
 * @discussion The bar background view displays behind the index bar when rendering. Change this property to customize the display of the bar background with a custom view.
 */
@property (strong, nonatomic) IBOutlet UIView *barBackgroundView;

/*!
 * @abstract String to display in place of items that have been truncated from the index bar.
 * @discussion GDIIndex bar is built to display truncated text when the index bar resizes and there is not enough vertical space to fit all indexes provided. When this happens, rows omitted in the display are replaced with the truncatedRowText value. Defaults to "•".
 */
@property (strong, nonatomic) NSString *truncatedRowText UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The vertical alignment of the index bar.
 * @discussion Property to determine the verical position of the text displayed in the index bar. Defaults to `GDIIndexBarAlignmentTop`.
 */
@property (nonatomic) GDIIndexBarAlignment verticalAlignment UI_APPEARANCE_SELECTOR;

/*!
 * @abstract Determines if the bar background should always show.
 * @discussion If YES, always displays the background bar. If NO, the bar background view is only displayed when a user taps on the index bar. This value uses an NSNumber instead of BOOL to conform to the UIAppearance protocol. Defaults to YES for iOS7 devices, and NO for iOS6.
 */
@property (strong, nonatomic) NSNumber *alwaysShowBarBackground UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The width of the hit area for the control.
 * @discussion This value must be greater than or equal to the `barBackgroundWidth` value. Default value is 44.
 */
@property (assign, nonatomic) CGFloat barWidth UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The width of the bar background view.
 * @discussion This value should be less than or equal to the `barWidth` value. This value is applied to the background view position.
 */
@property (assign, nonatomic) CGFloat barBackgroundWidth UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The color of the bar background view.
 * @discussion This value sets the background color of the bar background view, when provided. If the background view is nil, this property has no effect.
 */
@property (strong, nonatomic) UIColor *barBackgroundColor UI_APPEARANCE_SELECTOR;

/*!
 * @abstract Amount to offset the bar background frame.
 * @discussion Offsets the origin of the bar bacground frame. By default, views are centered within the index bar, using the barWidth value to determine the horizontal area to center within. The defaults value changes for iOS and iOS7 to support the different styles.
 */
@property (assign, nonatomic) UIOffset barBackgroundOffset UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The corner radius of the bar background view's layer.
 * @discussion This value sets the `cornerRadius` value of the `barBackgroundView`'s  layer. If the background view is nil, this property has no effect. Defaults to 12 on iOS6, and 0 for iOS7 and later.
 */
@property (assign, nonatomic) CGFloat barBackgroundCornerRadius UI_APPEARANCE_SELECTOR;

/*!
 * @abstract Offsets the position of the text drawing.
 * @discussion Offsets the origin of the standard text area frame. By default, views are centered within the index bar, using the barWidth value to determine the horizontal area to center within. The defaults value changes for iOS and iOS7 to support the different styles.
 */
@property (nonatomic) UIOffset textOffset UI_APPEARANCE_SELECTOR;

/*!
 * @abstract Font for the index bar text.
 * @discussion Defaults to Helvetica Neue Bold 11pt.
 */
@property (strong, nonatomic) UIFont *textFont UI_APPEARANCE_SELECTOR;

/*!
 * @abstract Sets the text color for the index bar text.
 * @discussion Defaults to blue on iOS7 and later, and gray for iOS6.
 */
@property (strong, nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;

/*!
 * @abstract Amount of vertical spacing between each letter of index bar.
 * @discussion Defaults to 2.0.
 */
@property (assign, nonatomic) CGFloat textSpacing UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The shadow color for the index bar text.
 */
@property (strong, nonatomic) UIColor *textShadowColor UI_APPEARANCE_SELECTOR;

/*!
 * @abstract The offset for the shadow color of the index bar text.
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