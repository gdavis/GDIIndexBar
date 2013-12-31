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

typedef enum GDIIndexBarAlignment {
    GDIIndexBarAlignmentTop,
    GDIIndexBarAlignmentCenter,
    GDIIndexBarAlignmentBottom
} GDIIndexBarAlignment;

@protocol GDIIndexBarDelegate;
@interface GDIIndexBar : UIView

@property (nonatomic) GDIIndexBarAlignment verticalAlignment;
@property (weak, nonatomic) IBOutlet id <GDIIndexBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *barBackgroundView;

@property (nonatomic) CGFloat barWidth;
@property (nonatomic) CGFloat textSpacing;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) UIOffset textShadowOffset;

@property (strong, nonatomic) UIColor *textColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *textShadowColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *textFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *barBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

/*!
 * Adjusts the inset of the index bar from the top and right side of the table view.
 */
@property (nonatomic) UIOffset edgeOffset;

/*!
 * Initializes the index bar with an associated table view.
 */
- (id)initWithTableView:(UITableView *)tableView;

/*!
 * Reloads the index bar by asking the delegate for new display information.
 */
- (void)reload;

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