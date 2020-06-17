//
//  ScrollableTextField-OC.h
//  ScrollableTextField
//
//  Created by Sun,Shuyao on 2020/6/17.
//  Copyright © 2020 Sun,Shuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TextRangeChangedType) {
    TextRangeChangedTypeLeftAndBack,
    TextRangeChangedTypeLeftAndForward,
    TextRangeChangedTypeRightAndBack,
    TextRangeChangedTypeRightAndForward,
    TextRangeChangedTypeNone
};

NS_ASSUME_NONNULL_BEGIN

@interface ScrollableTextField_OC : UIView

/// Real textFiled.
///
/// You should set delegate, add actions or resign first responder  to this view.
@property (nonatomic, readonly, strong) UITextField *textField;

@end

typedef void(^SelectedTextRangeChangedBlock)(TextRangeChangedType changeType, CGFloat beforeTextWidth);

@interface InnerTextField : UITextField

- (nullable NSNumber *)getWidthFromDocumentBeginingToCursor;

- (nullable NSNumber *)getWidthFromDocumentBeginingToEnd;

@property (nonatomic, strong) SelectedTextRangeChangedBlock selectedTextRangeChangedBlock;

@end

NS_ASSUME_NONNULL_END
