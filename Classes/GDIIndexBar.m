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
#define kStandardButtonWidth 44.f
#define kShowDebugOutlines 1

@implementation GDIIndexBar {
    NSUInteger _numberOfIndexes;
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
    _edgeOffset = UIOffsetMake(-3, 0);
    _textShadowOffset = UIOffsetMake(1.f, 1.f);
    _textAlignment = NSTextAlignmentCenter;
    _textSpacing = 2.f;
    _barWidth = kDefaultIndexBarWidth;
    _barBackgroundColor = [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:.9f];
    
#if kShowDebugOutlines
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = .5f;
    self.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:1.f alpha:.2f];
#else
    self.backgroundColor = [UIColor clearColor];
#endif
    
    if (_tableView && _delegate) {
        [self reload];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange
{
    [self setNeedsLayout];
    [self setNeedsDisplay];
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
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.superview == _tableView) {
        _tableView.canCancelContentTouches = NO;
        _tableView.delaysContentTouches = NO;
    }
    
    CGPoint relativeTableViewTopRightPoint = [self.superview convertPoint:CGPointMake(_tableView.frame.size.width, 0) fromView:_tableView];
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
    self.barBackgroundView.frame = [self rectForTextArea];
    
    // when our parent view is a table, make sure we are always on top.
    // fix fixes issues where header views can be placed on top of the index bar.
    if ([self.superview isKindOfClass:[UITableView class]]) {
        [self.superview bringSubviewToFront:self];
    }
}

CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
};


- (CGRect)rectForTextArea
{
    CGRect tableRect = self.tableView.frame;
    CGFloat indexRowHeight = _textSpacing + _lineHeight;
    CGFloat height = indexRowHeight * _numberOfIndexes + _textSpacing * 2;
    CGRect parentInsetRect = self.superview.frame;
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        parentInsetRect = UIEdgeInsetsInsetRect(self.superview.frame, scrollView.contentInset);
    }
    
    // if the height for all indexes is too large, display as many as we can
    if (height > tableRect.size.height) {
        height = floorf(tableRect.size.height / indexRowHeight) * _lineHeight;
    }
    
    CGFloat yp;
    switch (_verticalAlignment) {
        case GDIIndexBarAlignmentTop:
            yp = _edgeOffset.vertical;
            break;
        
        case GDIIndexBarAlignmentBottom:
            yp = self.frame.size.height - _edgeOffset.vertical - height;
            break;
            
        case GDIIndexBarAlignmentCenter:
        default:
            yp = parentInsetRect.size.height * .5 - height * .5 + _edgeOffset.vertical;
            break;
    }
    
    return CGRectMake(0, yp, _barWidth, height);
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSUInteger indexCount = [self.delegate numberOfIndexesForIndexBar:self];
    CGRect textAreaRect = [self rectForTextArea];
    CGFloat yp = _textSpacing + textAreaRect.origin.y + _edgeOffset.vertical;
    
    // draw debug box for text area
#if kShowDebugOutlines
    CGContextSetLineWidth(ctx, 2.f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextStrokeRect(ctx, textAreaRect);
#endif
    
    for (int i = 0; i < indexCount; i++) {
        
        NSString *text;
        // ask delegate for text to show
        if ([self.delegate respondsToSelector:@selector(stringForIndex:)]) {
            text = [self.delegate stringForIndex:i];
        }
        // otherwise use default text values
        else text = [NSString stringWithFormat:@"%i", i];
        
        CGSize textSize = [text sizeWithFont:self.textFont];
        CGPoint point = CGPointMake(rect.size.width * .5 - textSize.width * .5 + _edgeOffset.horizontal, yp);
        CGPoint shadowPoint = CGPointAdd(point, CGPointMake(self.textShadowOffset.horizontal, self.textShadowOffset.vertical));
        
        // draw shadow color
        [self.textShadowColor set];
        [text drawInRect:CGRectMake(shadowPoint.x, shadowPoint.y, textSize.width, _lineHeight)
                withFont:self.textFont
           lineBreakMode:NSLineBreakByClipping
               alignment:_textAlignment];
        
        // draw normal color
        [self.textColor set];
        [text drawInRect:CGRectMake(point.x, point.y, textSize.width, _lineHeight)
                withFont:self.textFont
           lineBreakMode:NSLineBreakByClipping
               alignment:_textAlignment];
        
        yp += _lineHeight + _textSpacing;
    }
}

#pragma mark - Touch Handling

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches.allObjects lastObject];
    if (CGRectContainsPoint([self rectForTextArea], [touch locationInView:self])) {
        _currentTouch = touch;
        [self handleTouch:_currentTouch];
    }
    else {
        [super touchesBegan:touches withEvent:event];
        [self.nextResponder touchesBegan:touches withEvent:event];
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
        CGPoint pointInTextArea = CGPointMake(touchPoint.x, touchPoint.y - textAreaRect.origin.y);
        CGFloat progress = fmaxf(0.f, fminf(pointInTextArea.y / textAreaRect.size.height, 1.f));
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

- (UIView *)barBackgroundView
{
    if (_barBackgroundView == nil) {
        _barBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _barBackgroundView.backgroundColor = self.barBackgroundColor;
    }
    return _barBackgroundView;
}

@end
