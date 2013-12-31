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
#define kDefaultIndexBarWidth 25.f
#define kDefaultFontName @"Helvetica"
#define kDefaultFontSize 12.f

@implementation GDIIndexBar {
    NSUInteger _numberOfIndexes;
    CGFloat _indexBarWidth;
    CGFloat _lineHeight;
    NSDictionary *_textAttributes;
    UITouch *_currentTouch;
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
    _verticalAlignment = GDIIndexBarAlignmentCenter;
    _edgeOffset = UIOffsetMake(10.f, 0.f);
    _textShadowOffset = UIOffsetMake(1.f, 1.f);
    _textAlignment = NSTextAlignmentCenter;
    _textSpacing = 2.f;
    
    if (_tableView && _delegate) {
        [self reload];
    }
    self.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:1.f alpha:1.f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange
{
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
        _tableView.canCancelContentTouches = NO;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat viewWidth = _indexBarWidth;
    CGFloat viewHeight = fminf((_lineHeight + _textSpacing) * _numberOfIndexes + _textSpacing * 2, self.superview.frame.size.height);
    CGRect parentInsetRect = self.superview.frame;
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        parentInsetRect = UIEdgeInsetsInsetRect(self.superview.frame, scrollView.contentInset);
    }
    
    // create our origin, right justified and include edge offsets
    CGPoint origin;
    switch (self.verticalAlignment) {
    
        case GDIIndexBarAlignmentCenter:
            origin = CGPointMake(self.superview.frame.size.width - _edgeOffset.horizontal - viewWidth,
                                 CGRectGetMidY(parentInsetRect) + _edgeOffset.vertical - viewHeight);
            break;
        
        case GDIIndexBarAlignmentBottom:
            origin = CGPointMake(self.superview.frame.size.width - _edgeOffset.horizontal - viewWidth,
                                 parentInsetRect.size.height - viewHeight - _edgeOffset.vertical);
            break;
            
        case GDIIndexBarAlignmentTop:
        default:
            origin = CGPointMake(self.superview.frame.size.width - _edgeOffset.horizontal - viewWidth,
                                 _edgeOffset.vertical);
            break;
    }
    
    // here we check if our parent view is a scroll view, and if it is,
    // add its offset and insets to our origin to keep it fixed
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        origin = CGPointAdd(origin, scrollView.contentOffset);
        origin = CGPointAdd(origin, CGPointMake(0, scrollView.contentInset.top));
    }
    
    CGRect rect = CGRectMake(origin.x, origin.y, viewWidth, viewHeight);
    self.frame = rect;
    
    // when our parent view is a table, make sure we are always on top.
    // fix fixes issues where header views can be placed on top of the index bar.
    if ([self.superview isKindOfClass:[UITableView class]]) {
        [self.superview bringSubviewToFront:self];
    }
}

CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
};

#pragma mark - Public API

- (void)reload
{
    // check delegate
    NSAssert([self.delegate respondsToSelector:@selector(numberOfIndexesForIndexBar:)], @"Delegate must implement numberOfIndexesForIndexBar:");
    NSAssert([self.delegate respondsToSelector:@selector(stringForIndex:)], @"Delegate must implement stringForIndex:");
    _numberOfIndexes = [self.delegate numberOfIndexesForIndexBar:self];
    
    // check table view
    NSAssert(self.tableView, @"Table view cannot be nil.");
    
    // get dimensions
    if ([self.delegate respondsToSelector:@selector(widthForIndexBar:)]) {
        _indexBarWidth = [self.delegate widthForIndexBar:self];
    }
    else {
        _indexBarWidth = kDefaultIndexBarWidth;
    }
    
    _lineHeight = [@"0" sizeWithAttributes:[self textAttributes]].height;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - Display

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if ([self.delegate respondsToSelector:@selector(numberOfIndexesForIndexBar:)]) {
        
        NSUInteger indexCount = [self.delegate numberOfIndexesForIndexBar:self];
        CGFloat yp = _textSpacing;
        
        for (int i = 0; i < indexCount; i++) {
            
            NSString *text;
            // ask delegate for text to show
            if ([self.delegate respondsToSelector:@selector(stringForIndex:)]) {
                text = [self.delegate stringForIndex:i];
            }
            // otherwise use default text values
            else text = [NSString stringWithFormat:@"%i", i];
            
            CGPoint point = CGPointMake(0, yp);
            CGPoint offsetPoint = CGPointAdd(point, CGPointMake(self.textShadowOffset.horizontal, self.textShadowOffset.vertical));
            
            // draw shadow color
            CGContextSetFillColorWithColor(ctx, self.textShadowColor.CGColor);
            [text drawInRect:CGRectMake(offsetPoint.x, offsetPoint.y, _indexBarWidth, _lineHeight)
                    withFont:self.textFont
               lineBreakMode:NSLineBreakByClipping
                   alignment:_textAlignment];
            
            // draw normal color
            CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
            [text drawInRect:CGRectMake(point.x, point.y, _indexBarWidth, _lineHeight)
                    withFont:self.textFont
               lineBreakMode:NSLineBreakByClipping
                   alignment:_textAlignment];
            
            yp += _lineHeight + _textSpacing;
        }
    }
}

#pragma mark - Touch Handling

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_currentTouch == nil) {
        _currentTouch = [touches.allObjects lastObject];
    }
    [self handleTouch:_currentTouch];
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
        [self handleTouch:_currentTouch];
        _currentTouch = nil;
    }
}

- (void)handleTouch:(UITouch *)touch
{
    if ([self.delegate respondsToSelector:@selector(indexBar:didSelectIndex:)]) {
        CGPoint touchPoint = [touch locationInView:self];
        CGFloat progress = fmaxf(0.f, fminf(touchPoint.y / self.frame.size.height, 1.f));
        NSUInteger index = floorf(progress * (_numberOfIndexes-1));
        [self.delegate indexBar:self didSelectIndex:index];
    }
}


#pragma mark - Appearance

- (NSDictionary *)textAttributes
{
    if (_textAttributes == nil) {
        _textAttributes = @{ UITextAttributeFont: self.textFont,
                             UITextAttributeTextColor: self.textColor,
                             UITextAttributeTextShadowColor: self.textShadowColor,
                            };
    }
    return _textAttributes;
}


- (UIColor *)textColor
{
    if(_textColor == nil) {
        _textColor = [[[self class] appearance] textColor];
    }
    if(_textColor != nil) {
        return _textColor;
    }
    return [UIColor whiteColor];
}


- (UIColor *)textShadowColor
{
    if(_textShadowColor == nil) {
        _textShadowColor = [[[self class] appearance] textColor];
    }
    if(_textShadowColor != nil) {
        return _textShadowColor;
    }
    return [UIColor blackColor];
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


@end
