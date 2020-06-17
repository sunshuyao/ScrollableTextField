//
//  ScrollableTextField-OC.m
//  ScrollableTextField
//
//  Created by Sun,Shuyao on 2020/6/17.
//  Copyright © 2020 Sun,Shuyao. All rights reserved.
//

#import "ScrollableTextField-OC.h"

static const CGFloat kOneCutWidth = 414;
static const CGFloat kDefaultCutTimes = 3;

@interface ScrollableTextField_OC () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) NSLayoutConstraint *textFiledWidthConstraint;

@end

@implementation ScrollableTextField_OC

- (void)configureSubviews {
    // scroll
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.contentSize = CGSizeMake(kOneCutWidth * kDefaultCutTimes, 0);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = UIColor.clearColor;
    [self addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *scrollLeftCons = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:0];
    NSLayoutConstraint *scrollRightCons = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *scrollTopCons = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *scrollBottomCons = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    [self addConstraints:@[scrollLeftCons, scrollRightCons, scrollTopCons, scrollBottomCons]];
    
    // text field
    InnerTextField *newTextField = [[InnerTextField alloc] initWithFrame:CGRectZero];
    _textField = newTextField;
    [newTextField addTarget:self action:@selector(handleTextField) forControlEvents:UIControlEventEditingChanged];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGesture.delegate = self;
    [newTextField addGestureRecognizer:_tapGesture];
    __weak typeof(self) ws = self;
    newTextField.selectedTextRangeChangedBlock = ^(TextRangeChangedType changeType, CGFloat beforeTextWidth) {
        __strong typeof(self) ss = ws;
        if (!ss) {
            return;
        }
        CGFloat div = 15;
        CGPoint originOffset = ss->_scrollView.contentOffset;
        if (beforeTextWidth < ss->_scrollView.contentOffset.x + div) {
            [UIView animateWithDuration:0.1 animations:^{
                ss->_scrollView.contentOffset = CGPointMake(MAX(beforeTextWidth - div, 0), originOffset.y);
            }];
        } else if (beforeTextWidth > originOffset.x + ss->_scrollView.bounds.size.width - div) {
            [UIView animateWithDuration:0.1 animations:^{
                ss->_scrollView.contentOffset = CGPointMake(beforeTextWidth - ss->_scrollView.bounds.size.width + div, originOffset.y);
            }];
        }
    };
    [_scrollView addSubview:newTextField];
    newTextField.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *textLeftCons = [NSLayoutConstraint constraintWithItem:newTextField
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_scrollView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:0];
    NSLayoutConstraint *textTopCons = [NSLayoutConstraint constraintWithItem:newTextField
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *textBottomCons = [NSLayoutConstraint constraintWithItem:newTextField
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *textWidthCons = [NSLayoutConstraint constraintWithItem:newTextField
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:kOneCutWidth * kDefaultCutTimes];
    [_scrollView addConstraint:textLeftCons];
    [self addConstraints:@[textTopCons, textBottomCons]];
    [newTextField addConstraint:textWidthCons];
    _textFiledWidthConstraint = textWidthCons;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubviews];
    }
    return self;
}

- (void)handleTextField {
    InnerTextField *hookedTF = (InnerTextField *)_textField;
    if (![hookedTF isKindOfClass:InnerTextField.class]) {
        return;
    }
    NSNumber *width = [hookedTF getWidthFromDocumentBeginingToCursor];
    NSNumber *fullWidth = [hookedTF getWidthFromDocumentBeginingToEnd];
    if (!width || !fullWidth) {
        return;
    }
    CGFloat selfWidth = self.bounds.size.width;
    if (selfWidth == 0) {
        return;
    }
    //check max bounds
    CGSize originContentSize = _scrollView.contentSize;
    if (_scrollView.contentSize.width - fullWidth.doubleValue < kOneCutWidth) {
        if (_scrollView.contentSize.width <= fullWidth.doubleValue) {
            _scrollView.contentSize = CGSizeMake(fullWidth.doubleValue + kOneCutWidth, originContentSize.height);
        } else {
            _scrollView.contentSize = CGSizeMake(originContentSize.width + kOneCutWidth, originContentSize.height);
        }
        _textFiledWidthConstraint.constant = _scrollView.contentSize.width;
        [self layoutIfNeeded];
    }
    CGPoint originOffset = _scrollView.contentOffset;
    if (width.doubleValue >= selfWidth - 3) {
        if (width.doubleValue - originOffset.x >= 0 && width.doubleValue - originOffset.x < selfWidth) {
            return;
        }
        CGFloat diff = MAX(width.doubleValue - selfWidth + 3, 0);
        _scrollView.contentOffset = CGPointMake(diff, originOffset.y);
    } else {
        _scrollView.contentOffset = CGPointMake(0, originOffset.y);
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_textField];
    UITextPosition *closestPosition = [_textField closestPositionToPoint:point];
    if (closestPosition) {
        _textField.selectedTextRange = [_textField textRangeFromPosition:closestPosition toPosition:closestPosition];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    InnerTextField *textField = (InnerTextField *)_textField;
    if (![textField isKindOfClass:InnerTextField.class]) {
        return;
    }
    NSNumber *currentTextWidth = [textField getWidthFromDocumentBeginingToEnd];
    if (!currentTextWidth) {
        return;
    }
    CGFloat selfWidth = self.frame.size.width;
    CGPoint originOffset = _scrollView.contentOffset;
    if (currentTextWidth.doubleValue < selfWidth) {
        _scrollView.contentOffset = CGPointMake(0, originOffset.y);
        return;
    }
    CGFloat maxOffsetX = currentTextWidth.doubleValue - selfWidth + 6;
    if (_scrollView.contentOffset.x > maxOffsetX) {
        _scrollView.contentOffset = CGPointMake(maxOffsetX, originOffset.y);
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.tapGesture) {
        return _textField.isFirstResponder;
    }
    return YES;
}

@end

@implementation InnerTextField

- (nullable NSNumber *)getWidthFromDocumentBeginingToCursor {
    UITextRange *selectedRange = self.selectedTextRange;
    if (selectedRange) {
        return [self getWidthFromDocumentBeginingToPosition:selectedRange.start];
    }
    return nil;
}

- (nullable NSNumber *)getWidthFromDocumentBeginingToEnd {
    NSString *str = self.text;
    if (str) {
        return @([self getWidthFromString:str]);
    }
    return nil;
}

- (TextRangeChangedType)changeTypeFromOldRange:(UITextRange *)oldRange toNewRange:(UITextRange *)newRange {
    NSInteger oldStart = [self offsetFromPosition:self.beginningOfDocument toPosition:oldRange.start];
    NSInteger oldEnd = [self offsetFromPosition:self.beginningOfDocument toPosition:oldRange.end];
    
    NSInteger newStart = [self offsetFromPosition:self.beginningOfDocument toPosition:newRange.start];
    NSInteger newEnd = [self offsetFromPosition:self.beginningOfDocument toPosition:newRange.end];
    
    if (oldStart == newStart && oldEnd != newEnd) {
        if (newEnd > oldEnd) {
            return TextRangeChangedTypeRightAndForward;
        } else if (newEnd < oldEnd) {
            return TextRangeChangedTypeRightAndBack;
        }
        return TextRangeChangedTypeNone;
    }
    if (oldStart != newStart && oldEnd == newEnd) {
        if (newStart < oldStart) {
            return TextRangeChangedTypeLeftAndBack;
        } else if (newStart > oldStart) {
            return TextRangeChangedTypeLeftAndForward;
        }
        return TextRangeChangedTypeNone;
    }
    if (oldStart == oldEnd && newStart == newEnd) {
        if (newStart > oldStart) {
            return TextRangeChangedTypeRightAndForward;
        } else if (newStart < oldStart) {
            return TextRangeChangedTypeLeftAndBack;
        }
    }
    return TextRangeChangedTypeNone;
}

- (CGFloat)getWidthFromString:(NSString *)text {
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.text = text;
    UIFont *font = self.font ? : [UIFont systemFontOfSize:15];
    newLabel.font = font;
    [newLabel sizeToFit];
    return newLabel.bounds.size.width;
}

- (nullable NSNumber *)getWidthFromDocumentBeginingToPosition:(UITextPosition *)position {
    NSString *curText = self.text;
    if (!curText) {
        return nil;
    }
    NSInteger offset = [self offsetFromPosition:self.beginningOfDocument toPosition:position];
    if (offset <= curText.length && offset >= 0) {
        NSString *subStr = [curText substringToIndex:offset];
        CGFloat width = [self getWidthFromString:subStr];
        return @(width);
    } else {
        return nil;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    UITextRange *oldVal = self.selectedTextRange;
    UITextRange *newVal = selectedTextRange;
    if (oldVal && newVal) {
        TextRangeChangedType willChangeType = [self changeTypeFromOldRange:oldVal toNewRange:newVal];
        NSNumber *width = nil;
        if (willChangeType == TextRangeChangedTypeLeftAndBack || willChangeType == TextRangeChangedTypeLeftAndForward) {
            width = [self getWidthFromDocumentBeginingToPosition:newVal.start];
        } else if (willChangeType == TextRangeChangedTypeRightAndForward || willChangeType == TextRangeChangedTypeRightAndBack) {
            width = [self getWidthFromDocumentBeginingToPosition:newVal.end];
        }
        if (width && _selectedTextRangeChangedBlock) {
            _selectedTextRangeChangedBlock(willChangeType, width.floatValue);
        }
    }
    [super setSelectedTextRange:selectedTextRange];
}

@end
