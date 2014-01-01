//
//  GDIIndexBar.m
//  GDIIndexBar
//
//  Created by Grant Davis on 12/31/13.
//  Copyright (c) 2013 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GDIIndexBar.h"

#define kObservingContext @"GDIIndexBarContext"
#define kObservingKeyPath @"bounds"
#define kDefaultBarBackgroundWidth 25.f
#define kDefaultBarBackgroundWidthiOS7 15.f
#define kDefaultFontName @"HelveticaNeue-Bold"
#define kDefaultFontSize 11.f
#define kDefaultTextSpacing 2.f
#define kStandardButtonWidth 44.f
#define kShowDebugOutlines 0

@implementation GDIIndexBar {
    NSUInteger _numberOfIndexes;
    CGFloat _lineHeight;
    NSDictionary *_textAttributes;
    UITouch *_currentTouch;
    NSMutableArray *_indexStrings;
    NSArray *_displayedIndexStrings;
}

#pragma mark - Lifecycle

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.tableView = tableView;
        [self initIndexBar];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initIndexBar];
}

- (void)initIndexBar
{
    self.exclusiveTouch = YES;
    self.multipleTouchEnabled = NO;
    
    [self applyDefaultStyle];
    
    if (_tableView && _delegate) {
        [self reload];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        scrollView.delaysContentTouches = NO;
        NSLog(@"[GDIIndexBar] WARNING: Adding a GDIIndexBar as a subview of a UIScrollView will cause `delaysContentTouches` to be set to `NO`.");
    }
}

#pragma mark - Public API

- (void)reload
{
    // check delegate
    NSAssert([self.delegate respondsToSelector:@selector(numberOfIndexesForIndexBar:)], @"Delegate must implement numberOfIndexesForIndexBar:");
    NSAssert([self.delegate respondsToSelector:@selector(stringForIndex:)], @"Delegate must implement stringForIndex:");
    _numberOfIndexes = [self.delegate numberOfIndexesForIndexBar:self];
    
    // check table view
    NSAssert(self.tableView, @"Table view cannot be nil.");
    
    _lineHeight = [@"0" sizeWithFont:self.textFont].height;
    
    _indexStrings = [NSMutableArray array];
    for (int i = 0; i < _numberOfIndexes; i++) {
        [_indexStrings addObject:[self.delegate stringForIndex:i]];
    }
    
    [self setNeedsLayout];
}


#pragma mark - Property Setters

- (void)setDelegate:(id<GDIIndexBarDelegate>)delegate
{
    _delegate = delegate;
    if (_delegate && _tableView) {
        [self reload];
    }
}

- (void)setTableView:(UITableView *)tableView
{
    if (_tableView) {
        [_tableView removeObserver:self forKeyPath:kObservingKeyPath context:kObservingContext];
    }
    _tableView = tableView;
    if (_tableView) {
        [tableView addObserver:self forKeyPath:kObservingKeyPath options:0 context:kObservingContext];
    }
}


#pragma mark - Observing scroll view changes

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == kObservingContext && [keyPath isEqualToString:kObservingKeyPath]) {
        [self setNeedsLayout];
    }
}

#pragma mark - Layout

// this method creates an array of the available strings and truncates
// the array if needed to fit the current viewable area.
- (void)updateDisplayedIndexStrings
{
    CGFloat rowHeight = _lineHeight + _textSpacing;
    CGFloat desiredHeight = _textSpacing * 2 + rowHeight * _numberOfIndexes;
    if (desiredHeight > self.bounds.size.height) {
        
        NSMutableArray *displayedStrings = [NSMutableArray arrayWithArray:_indexStrings];
        NSUInteger numberOfRowsThatFit = floorf(self.bounds.size.height / rowHeight);
        NSUInteger hiddenRows = _numberOfIndexes - numberOfRowsThatFit;
        
        // determine which indexes will be removed from the displayed strings.
        // divide the number of indexes by the number of hidden rows plus 2
        // so that we may omit the first and last indexes and remove the
        // indexes at set intervals.
        NSUInteger indexInterval = _numberOfIndexes / (hiddenRows + 2);
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (int i = 0; i < hiddenRows; i++) {
            [indexSet addIndex:indexInterval * (i+1)];
        }
        [displayedStrings removeObjectsAtIndexes:indexSet];
        
        _displayedIndexStrings = [NSArray arrayWithArray:displayedStrings];
    }
    else {
        _displayedIndexStrings = [NSArray arrayWithArray:_indexStrings];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint relativeTableViewTopRightPoint = [self.superview convertPoint:CGPointMake(_tableView.frame.origin.x + _tableView.frame.size.width, 0)
                                                                 fromView:_tableView];
    CGPoint origin = CGPointMake(relativeTableViewTopRightPoint.x - _barWidth,
                                 relativeTableViewTopRightPoint.y);
    
    CGFloat height = _tableView.frame.size.height;
    
    // here we check if our parent view is a scroll view, and if it is,
    // add its offset and insets to our origin to keep it fixed
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        origin = CGPointAdd(origin, scrollView.contentOffset);
        origin = CGPointAdd(origin, CGPointMake(0, scrollView.contentInset.top));
        height -= (scrollView.contentInset.top + scrollView.contentInset.bottom);
    }
    
    CGSize size = CGSizeMake(_barWidth, height);
    self.frame = (CGRect){ origin, size };
    self.barBackgroundView.frame = [self rectForBarBackgroundView];
    
    // when our parent view is a table, make sure we are always on top.
    // fix fixes issues where header views can be placed on top of the index bar.
    if ([self.superview isKindOfClass:[UITableView class]]) {
        [self.superview bringSubviewToFront:self];
    }
    
    [self setNeedsDisplay];
}


CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
};


- (CGRect)rectForTextArea
{
    CGFloat indexRowHeight = _textSpacing + _lineHeight;
    CGFloat height = indexRowHeight * [self numberOfDisplayableRows] + _textSpacing * 2;
    CGRect parentInsetRect = self.superview.frame;
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        parentInsetRect = UIEdgeInsetsInsetRect(self.superview.frame, scrollView.contentInset);
    }
    
    CGFloat yp;
    switch (_verticalAlignment) {
        case GDIIndexBarAlignmentTop:
            yp = _textOffset.vertical;
            break;
        
        case GDIIndexBarAlignmentBottom:
            yp = self.frame.size.height - _textOffset.vertical - height;
            break;
            
        case GDIIndexBarAlignmentCenter:
        default:
            yp = parentInsetRect.size.height * .5 - height * .5 + _textOffset.vertical;
            break;
    }

    yp = fmaxf(0.f, yp);
    
    return CGRectMake(0, yp, _barWidth, height);
}


- (CGRect)rectForBarBackgroundView
{
    if ([self isOS7OrLater]) {
        
        return CGRectMake(_barWidth * .5 - _barBackgroundWidth * .5 + _barBackgroundOffset.horizontal,
                          0,
                          _barBackgroundWidth,
                          self.frame.size.height);
    }
    
    CGRect textAreaRect = [self rectForTextArea];
    return CGRectMake(_barWidth * .5 - _barBackgroundWidth * .5 + _barBackgroundOffset.horizontal,
                      textAreaRect.origin.y + _barBackgroundOffset.vertical,
                      _barBackgroundWidth,
                      textAreaRect.size.height);
}


- (NSUInteger)numberOfDisplayableRows
{
    CGFloat rowHeight = _lineHeight + _textSpacing;
    CGFloat desiredHeight = _textSpacing * 2 + rowHeight * _numberOfIndexes;
    if (desiredHeight > self.bounds.size.height) {
        NSUInteger numberOfRowsThatFit = floorf(self.bounds.size.height / rowHeight);
        return numberOfRowsThatFit;
    }
    return _numberOfIndexes;
}


- (void)deviceOrientationDidChange
{
    [self setNeedsLayout];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self updateDisplayedIndexStrings];
    
    NSUInteger indexCount = _displayedIndexStrings.count;
    CGRect barBackgroundRect = [self rectForBarBackgroundView];
    CGRect textAreaRect = [self rectForTextArea];
    CGFloat yp = _textSpacing + textAreaRect.origin.y + _textOffset.vertical;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw debug box for text area
#if kShowDebugOutlines
    CGContextSetLineWidth(ctx, 2.f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor orangeColor].CGColor);
    CGContextStrokeRect(ctx, textAreaRect);
#endif
    
    CGContextTranslateCTM(ctx, barBackgroundRect.origin.x, barBackgroundRect.origin.y);
    [self.barBackgroundView.layer renderInContext:ctx];
    CGContextTranslateCTM(ctx, -barBackgroundRect.origin.x, -barBackgroundRect.origin.y);
    
    for (int i = 0; i < indexCount; i++) {
        NSString *text = [_displayedIndexStrings objectAtIndex:i];
        CGSize textSize = [text sizeWithFont:self.textFont];
        CGPoint point = CGPointMake(rect.size.width * .5 - textSize.width * .5 + _textOffset.horizontal, yp);
        CGPoint shadowPoint = CGPointAdd(point, CGPointMake(self.textShadowOffset.horizontal, self.textShadowOffset.vertical));
        
        // draw shadow color
        [self.textShadowColor set];
        [text drawInRect:CGRectMake(shadowPoint.x, shadowPoint.y, textSize.width, _lineHeight)
                withFont:self.textFont];
        
        // draw normal color
        [self.textColor set];
        [text drawInRect:CGRectMake(point.x, point.y, textSize.width, _lineHeight)
                withFont:self.textFont];
        
        yp += _lineHeight + _textSpacing;
    }
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches.allObjects lastObject];
    if (CGRectContainsPoint([self rectForTextArea], [touch locationInView:self])) {
        _currentTouch = touch;
        [self handleTouch:_currentTouch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        [self handleTouch:_currentTouch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        _currentTouch = nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        _currentTouch = nil;
    }
}

- (void)handleTouch:(UITouch *)touch
{
    if ([self.delegate respondsToSelector:@selector(indexBar:didSelectIndex:)]) {
        CGPoint touchPoint = [touch locationInView:self];
        CGRect textAreaRect = [self rectForTextArea];
        CGFloat progress = fmaxf(0.f, fminf((touchPoint.y - textAreaRect.origin.y) / textAreaRect.size.height, .999f));
        NSUInteger stringIndex = floorf(progress * _displayedIndexStrings.count);
        NSUInteger index = [_indexStrings indexOfObject:[_displayedIndexStrings objectAtIndex:stringIndex]];
        [self.delegate indexBar:self didSelectIndex:index];
    }
}

#pragma mark - Appearance

- (void)applyDefaultStyle
{
#if kShowDebugOutlines
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = .5f;
    self.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:1.f alpha:.2f];
#else
    self.backgroundColor = [UIColor clearColor];
#endif
    
    _verticalAlignment = GDIIndexBarAlignmentCenter;
    _textShadowOffset = UIOffsetZero;
    _textSpacing = kDefaultTextSpacing;
    _barWidth = kStandardButtonWidth;
    
    if ([self isOS7OrLater]) {
        _textOffset =
        _barBackgroundOffset = UIOffsetMake(14.5f, 0.f);
        _barBackgroundWidth = kDefaultBarBackgroundWidthiOS7;
        _barBackgroundColor = [UIColor colorWithWhite:1.f alpha:.9f];
    }
    else {
        _textOffset = UIOffsetZero;
        _barBackgroundOffset = UIOffsetZero;
        _barBackgroundColor = [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:.9f];
        _barBackgroundWidth = kDefaultBarBackgroundWidth;
    }
}

- (UIColor *)textColor
{
    if(_textColor == nil) {
        _textColor = [[[self class] appearance] textColor];
    }
    if(_textColor != nil) {
        return _textColor;
    }
    if ([self isOS7OrLater]) {
        return self.superview.tintColor;
    }
    return [UIColor grayColor];
}

- (UIColor *)textShadowColor
{
    if(_textShadowColor == nil) {
        _textShadowColor = [[[self class] appearance] textColor];
    }
    if(_textShadowColor != nil) {
        return _textShadowColor;
    }
    return [UIColor clearColor];
}

- (UIFont *)textFont
{
    if (_textFont == nil) {
        _textFont = [[[self class] appearance] textFont];
    }
    if (_textFont != nil) {
        return _textFont;
    }
    return [UIFont fontWithName:kDefaultFontName size:kDefaultFontSize];
}

- (UIView *)barBackgroundView
{
    if (_barBackgroundView == nil) {
        _barBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _barBackgroundView.backgroundColor = self.barBackgroundColor;
    }
    return _barBackgroundView;
}


- (BOOL)isOS7OrLater
{
    static BOOL _isOS7OrLater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isOS7OrLater = !(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1);
    });
    return _isOS7OrLater;
}

@end
