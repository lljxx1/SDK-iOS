//
//  UIView+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+BWHXMASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface MAS_VIEW (BWHXMASShorthandAdditions)

@property (nonatomic, strong, readonly) BWHXMASViewAttribute *left;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *top;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *right;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *bottom;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *leading;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *trailing;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *width;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *height;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *centerX;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *centerY;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *baseline;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) BWHXMASViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *lastBaseline;

#endif

#if TARGET_OS_IPHONE || TARGET_OS_TV

@property (nonatomic, strong, readonly) BWHXMASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *centerYWithinMargins;

#endif

- (NSArray *)makeConstraints:(void(^)(BWHXMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(BWHXMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(BWHXMASConstraintMaker *make))block;

@end

#define MAS_ATTR_FORWARD(attr)  \
- (MASViewAttribute *)attr {    \
    return [self mas_##attr];   \
}

@implementation MAS_VIEW (BWHXMASShorthandAdditions)

MAS_ATTR_FORWARD(top);
MAS_ATTR_FORWARD(left);
MAS_ATTR_FORWARD(bottom);
MAS_ATTR_FORWARD(right);
MAS_ATTR_FORWARD(leading);
MAS_ATTR_FORWARD(trailing);
MAS_ATTR_FORWARD(width);
MAS_ATTR_FORWARD(height);
MAS_ATTR_FORWARD(centerX);
MAS_ATTR_FORWARD(centerY);
MAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

MAS_ATTR_FORWARD(firstBaseline);
MAS_ATTR_FORWARD(lastBaseline);

#endif

#if TARGET_OS_IPHONE || TARGET_OS_TV

MAS_ATTR_FORWARD(leftMargin);
MAS_ATTR_FORWARD(rightMargin);
MAS_ATTR_FORWARD(topMargin);
MAS_ATTR_FORWARD(bottomMargin);
MAS_ATTR_FORWARD(leadingMargin);
MAS_ATTR_FORWARD(trailingMargin);
MAS_ATTR_FORWARD(centerXWithinMargins);
MAS_ATTR_FORWARD(centerYWithinMargins);

#endif

- (BWHXMASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(^)(BWHXMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(BWHXMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(BWHXMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
