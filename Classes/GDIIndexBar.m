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
#define kDefaultTruncatedRowText @"•"
#define kStandardButtonWidth 44.f
#define kShowDebugOutlines 0

@implementation GDIIndexBar {
    NSUInteger _numberOfIndexes;
    NSUInteger _lastSelectedStringIndex;
    CGFloat _lineHeight;
    NSDictionary *_textAttributes;
    UITouch *_currentTouch;
    NSMutableArray *_indexStrings;
    NSArray *_displayedIndexStrings;
}
@synthesize textColor = _textColor;
@synthesize textShadowColor = _textShadowColor;
@synthesize textFont = _textFont;
@synthesize barBackgroundColor = _barBackgroundColor;

#pragma mark - Class Methods

+ (void)initialize
{
    if (self == [GDIIndexBar class]) {
        GDIIndexBar *appearance = [self appearance];
        [appearance setVerticalAlignment:GDIIndexBarAlignmentCenter];
        [appearance setTextShadowOffset:UIOffsetZero];
        [appearance setTextSpacing:kDefaultTextSpacing];
        [appearance setBarWidth:kStandardButtonWidth];
        [appearance setTruncatedRowText:kDefaultTruncatedRowText];
        
        if ([self isOS7OrLater]) {
            UIOffset offset = UIOffsetMake(14.5f, 0.f);
            [appearance setTextOffset:offset];
            [appearance setBarBackgroundOffset:offset];
            [appearance setBarBackgroundWidth:kDefaultBarBackgroundWidthiOS7];
            [appearance setAlwaysShowBarBackground:@(YES)];
        }
        else {
            UIOffset offset = UIOffsetMake(3.5f, 0.f);
            [appearance setTextOffset:offset];
            [appearance setBarBackgroundOffset:offset];
            [appearance setBarBackgroundCornerRadius:12.f];
            [appearance setBarBackgroundWidth:kDefaultBarBackgroundWidth];
            [appearance setAlwaysShowBarBackground:@(NO)];
        }
    }
}

+ (BOOL)isOS7OrLater
{
    static BOOL isOS7OrLater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isOS7OrLater = !(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1);
    });
    return isOS7OrLater;
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
    _lastSelectedStringIndex = NSNotFound;

    self.exclusiveTouch = YES;
    self.multipleTouchEnabled = NO;
    
    [self applyDefaultStyle];
    
    if (_tableView && _delegate) {
        [self reload];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardFrameChange:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardFrameChange:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardFrameChange:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardFrameChange:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
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
        [scrollView addObserver:self forKeyPath:kObservingKeyPath options:0 context:kObservingContext];
        NSLog(@"[GDIIndexBar] WARNING: Adding a GDIIndexBar as a subview of a UIScrollView will cause `delaysContentTouches` to be set to `NO`.");
    }
    if (newSuperview == nil && [self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        [scrollView removeObserver:self forKeyPath:kObservingKeyPath context:kObservingContext];
    }
}

#pragma mark - Public API

- (void)reload
{
    NSAssert([self.delegate respondsToSelector:@selector(numberOfIndexesForIndexBar:)], @"Delegate must implement numberOfIndexesForIndexBar:");
    NSAssert([self.delegate respondsToSelector:@selector(stringForIndex:)], @"Delegate must implement stringForIndex:");
    NSAssert(self.tableView, @"Table view cannot be nil.");
    
    _numberOfIndexes = [self.delegate numberOfIndexesForIndexBar:self];
    _lineHeight = [@"0" sizeWithFont:self.textFont].height;
    _indexStrings = [NSMutableArray array];
    
    for (int i = 0; i < _numberOfIndexes; i++) {
        [_indexStrings addObject:[self.delegate stringForIndex:i]];
    }
    
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

#pragma mark - Observing scroll view changes

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == kObservingContext && [keyPath isEqualToString:kObservingKeyPath] && self.superview == _tableView) {
        [self setNeedsLayout];
    }
}

#pragma mark - Keyboard 

- (void)handleKeyboardFrameChange:(NSNotificationCenter *)note
{
    [self setNeedsLayout];
}

#pragma mark - Layout

// this method creates an array of the available strings and truncates
// the array if needed to fit the current viewable area.
- (void)updateDisplayedIndexStrings
{
    if ([self desiredHeight] > self.bounds.size.height) {
        
        NSMutableArray *displayedStrings = [NSMutableArray array];
        NSUInteger numberOfRowsThatFit = [self numberOfDisplayableRows];
        CGFloat step = (CGFloat)_indexStrings.count / numberOfRowsThatFit;
        CGFloat stepIndex = 0.f;
        
        for (int i=0; i < numberOfRowsThatFit; i++) {
            
            NSUInteger letterIndex = roundf(stepIndex);
            
            // for every other letter, use the truncated text string instead of the actual letter.
            if (i % 2 == 1) {
                [displayedStrings setObject:self.truncatedRowText atIndexedSubscript:i];
            }
            // otherwise, store the actual letter
            else {
                NSString *letter;
                if (letterIndex < _indexStrings.count) {
                    // if this is the last letter displayed, but is not using the last letter,
                    // then force the last letter to be displayed to footnote the bar
                    if (i+1 == numberOfRowsThatFit && letterIndex != numberOfRowsThatFit-1) {
                        letter = [_indexStrings lastObject];
                    }
                    else {
                        letter = [_indexStrings objectAtIndex:letterIndex];
                    }
                }
                else {
                    letter = [_indexStrings lastObject];
                }
                [displayedStrings setObject:letter atIndexedSubscript:i];
            }
            stepIndex += step;
        }
        _displayedIndexStrings = [NSArray arrayWithArray:displayedStrings];
    }
    else {
        _displayedIndexStrings = [NSArray arrayWithArray:_indexStrings];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGRect newFrame = [self rectForIndexBarFrame];
    BOOL hasNewSize = !CGSizeEqualToSize(self.frame.size, newFrame.size);
    
    self.frame = newFrame;
    self.barBackgroundView.frame = [self rectForBarBackgroundView];
    
    // when our parent view is a table, make sure we are always on top.
    // fix fixes issues where header views can be placed on top of the index bar.
    if ([self.superview isKindOfClass:[UITableView class]]) {
        [self.superview bringSubviewToFront:self];
    }
    
    if(hasNewSize) {
        [self setNeedsDisplay];
    }
}


CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
};


- (CGRect)rectForIndexBarFrame
{
    CGPoint relativeTableViewTopRightPoint = [_tableView convertPoint:CGPointMake(_tableView.frame.size.width, 0)
                                                               toView:self.superview];
    CGPoint origin = CGPointMake(relativeTableViewTopRightPoint.x - _barWidth,
                                 relativeTableViewTopRightPoint.y + _tableView.contentOffset.y + _tableView.contentInset.top);
    
    CGFloat height = _tableView.frame.size.height - (_tableView.contentInset.top + _tableView.contentInset.bottom);
    
    CGSize size = CGSizeMake(_barWidth, height);
    return (CGRect){ origin, size };
}


- (CGRect)rectForTextArea
{
    CGFloat indexRowHeight = _textSpacing + _lineHeight;
    CGFloat height = indexRowHeight * [self numberOfDisplayableRows] + _textSpacing * 2;
    CGRect parentInsetRect = [_tableView.superview convertRect:_tableView.frame
                                                        toView:self.superview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        parentInsetRect = UIEdgeInsetsInsetRect(scrollView.frame, scrollView.contentInset);
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
            yp = self.bounds.size.height * .5 - height * .5 + _textOffset.vertical;
            break;
    }

    yp = fmaxf(0.f, yp);
    
    return CGRectMake(0, yp, _barWidth, height);
}


- (CGRect)rectForBarBackgroundView
{
    if ([GDIIndexBar isOS7OrLater]) {
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


- (CGFloat)desiredHeight
{
    CGFloat rowHeight = _lineHeight + _textSpacing;
    return _textSpacing * 2 + rowHeight * _numberOfIndexes;
}


- (NSUInteger)numberOfDisplayableRows
{
    CGFloat rowHeight = _lineHeight + _textSpacing;
    CGFloat desiredHeight = _textSpacing * 2 + rowHeight * _numberOfIndexes;
    if (desiredHeight > self.bounds.size.height) {
        NSUInteger numberOfRowsThatFit = self.bounds.size.height / rowHeight;
        numberOfRowsThatFit -= (numberOfRowsThatFit%2==0) ? 1 : 0;
        return numberOfRowsThatFit;
    }
    return _numberOfIndexes;
}


- (void)deviceOrientationDidChange
{
    [self setNeedsLayout];
    [self setNeedsDisplay];
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
    
    if ([self.alwaysShowBarBackground boolValue] || self.isHighlighted) {
        CGContextTranslateCTM(ctx, barBackgroundRect.origin.x, barBackgroundRect.origin.y);
        [self.barBackgroundView.layer renderInContext:ctx];
        CGContextTranslateCTM(ctx, -barBackgroundRect.origin.x, -barBackgroundRect.origin.y);
    }
    
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
        self.highlighted = CGRectContainsPoint([self rectForTextArea], [_currentTouch locationInView:self]);
        [self handleTouch:_currentTouch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        self.highlighted = CGRectContainsPoint([self rectForTextArea], [_currentTouch locationInView:self]);
        [self handleTouch:_currentTouch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        self.highlighted = NO;
        _currentTouch = nil;
    }
    _lastSelectedStringIndex = NSNotFound;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        self.highlighted = NO;
        _currentTouch = nil;
    }
    _lastSelectedStringIndex = NSNotFound;
}

- (void)handleTouch:(UITouch *)touch
{
    if ([self.delegate respondsToSelector:@selector(indexBar:didSelectIndex:)]) {
        CGPoint touchPoint = [touch locationInView:self];
        CGRect textAreaRect = [self rectForTextArea];
        CGFloat progress = fmaxf(0.f, fminf((touchPoint.y - textAreaRect.origin.y) / textAreaRect.size.height, .999f));
        NSUInteger stringIndex = floorf(progress * _indexStrings.count);
        if (stringIndex != _lastSelectedStringIndex) {
            [self.delegate indexBar:self didSelectIndex:stringIndex];
            _lastSelectedStringIndex = stringIndex;
        }
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
    
    _verticalAlignment = [[[self class] appearance] verticalAlignment];
    _textShadowOffset = [[[self class] appearance] textShadowOffset];
    _textSpacing = [[[self class] appearance] textSpacing];
    _barWidth = [[[self class] appearance] barWidth];
    _textOffset = [[[self class] appearance] textOffset];
    _barBackgroundOffset = [[[self class] appearance] barBackgroundOffset];
    _barBackgroundWidth = [[[self class] appearance] barBackgroundWidth];
    _alwaysShowBarBackground = [[[self class] appearance] alwaysShowBarBackground];
    _barBackgroundCornerRadius = [[[self class] appearance] barBackgroundCornerRadius];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (UIColor *)textColor
{
    if(_textColor == nil) {
        _textColor = [[[self class] appearance] textColor];
    }
    if(_textColor != nil) {
        return _textColor;
    }
    if ([GDIIndexBar isOS7OrLater]) {
        return self.superview.tintColor;
    }
    return [UIColor grayColor];
}

- (void)setTextColor:(UIColor *)textColor
{
    [self willChangeValueForKey:@"textColor"];
    _textColor = textColor;
    [self didChangeValueForKey:@"textColor"];
    [self setNeedsDisplay];
}

- (UIColor *)textShadowColor
{
    if(_textShadowColor == nil) {
        _textShadowColor = [[[self class] appearance] textShadowColor];
    }
    if(_textShadowColor != nil) {
        return _textShadowColor;
    }
    return [UIColor clearColor];
}

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
    [self willChangeValueForKey:@"textShadowColor"];
    _textShadowColor = textShadowColor;
    [self didChangeValueForKey:@"textShadowColor"];
    [self setNeedsDisplay];
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

- (void)setTextFont:(UIFont *)textFont
{
    [self willChangeValueForKey:@"textFont"];
    _textFont = textFont;
    [self didChangeValueForKey:@"textFont"];
    [self setNeedsDisplay];
}

- (NSString *)truncatedRowText
{
    if (_truncatedRowText == nil) {
        _truncatedRowText = [[[self class] appearance] truncatedRowText];
    }
    if (_truncatedRowText != nil) {
        return _truncatedRowText;
    }
    return kDefaultTruncatedRowText;
}

- (UIColor *)barBackgroundColor
{
    if (_barBackgroundColor == nil) {
        _barBackgroundColor = [[[self class] appearance] barBackgroundColor];
    }
    if (_barBackgroundColor != nil) {
        return _barBackgroundColor;
    }
    if ([GDIIndexBar isOS7OrLater]) {
        return [UIColor colorWithWhite:1.f alpha:.9f];
    }
    return [UIColor colorWithRed:157/255.f green:165/255.f blue:169/255.f alpha:.8f];
}

- (void)setBarBackgroundColor:(UIColor *)barBackgroundColor
{
    [self willChangeValueForKey:@"barBackgroundColor"];
    _barBackgroundColor = barBackgroundColor;
    [self didChangeValueForKey:@"barBackgroundColor"];
    
    if (_barBackgroundView) {
        _barBackgroundView.backgroundColor = barBackgroundColor;
        [self setNeedsDisplay];
    }
}

- (void)setBarBackgroundCornerRadius:(CGFloat)barBackgroundCornerRadius
{
    [self willChangeValueForKey:@"barBackgroundCornerRadius"];
    _barBackgroundCornerRadius = barBackgroundCornerRadius;
    [self didChangeValueForKey:@"barBackgroundCornerRadius"];
    
    if (_barBackgroundView) {
        _barBackgroundView.layer.cornerRadius = barBackgroundCornerRadius;
        [self setNeedsDisplay];
    }
}

- (UIView *)barBackgroundView
{
    if (_barBackgroundView == nil) {
        _barBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _barBackgroundView.backgroundColor = self.barBackgroundColor;
        _barBackgroundView.layer.cornerRadius = self.barBackgroundCornerRadius;
    }
    return _barBackgroundView;
}

@end
