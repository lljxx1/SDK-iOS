//
//  UIView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+BWHXMASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (BWHXMASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(BWHXMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    BWHXMASConstraintMaker *constraintMaker = [[BWHXMASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(BWHXMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    BWHXMASConstraintMaker *constraintMaker = [[BWHXMASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(BWHXMASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    BWHXMASConstraintMaker *constraintMaker = [[BWHXMASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (BWHXMASViewAttribute *)mas_left {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (BWHXMASViewAttribute *)mas_top {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (BWHXMASViewAttribute *)mas_right {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (BWHXMASViewAttribute *)mas_bottom {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (BWHXMASViewAttribute *)mas_leading {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (BWHXMASViewAttribute *)mas_trailing {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (BWHXMASViewAttribute *)mas_width {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (BWHXMASViewAttribute *)mas_height {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (BWHXMASViewAttribute *)mas_centerX {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (BWHXMASViewAttribute *)mas_centerY {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (BWHXMASViewAttribute *)mas_baseline {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (BWHXMASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (BWHXMASViewAttribute *)mas_firstBaseline {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (BWHXMASViewAttribute *)mas_lastBaseline {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (BWHXMASViewAttribute *)mas_leftMargin {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (BWHXMASViewAttribute *)mas_rightMargin {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (BWHXMASViewAttribute *)mas_topMargin {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (BWHXMASViewAttribute *)mas_bottomMargin {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (BWHXMASViewAttribute *)mas_leadingMargin {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (BWHXMASViewAttribute *)mas_trailingMargin {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (BWHXMASViewAttribute *)mas_centerXWithinMargins {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (BWHXMASViewAttribute *)mas_centerYWithinMargins {
    return [[BWHXMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
    MAS_VIEW *closestCommonSuperview = nil;

    MAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        MAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
