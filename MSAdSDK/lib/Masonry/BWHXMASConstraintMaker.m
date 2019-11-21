//
//  MASConstraintBuilder.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "BWHXMASConstraintMaker.h"
#import "BWHXMASViewConstraint.h"
#import "BWHXMASCompositeConstraint.h"
#import "BWHXMASConstraint+Private.h"
#import "BWHXMASViewAttribute.h"
#import "View+BWHXMASAdditions.h"

@interface BWHXMASConstraintMaker () <BWHXMASConstraintDelegate>

@property (nonatomic, weak) MAS_VIEW *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation BWHXMASConstraintMaker

- (id)initWithView:(MAS_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [BWHXMASViewConstraint installedConstraintsForView:self.view];
        for (BWHXMASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (BWHXMASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - MASConstraintDelegate

- (void)constraint:(BWHXMASConstraint *)constraint shouldBeReplacedWithConstraint:(BWHXMASConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (BWHXMASConstraint *)constraint:(BWHXMASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    BWHXMASViewAttribute *viewAttribute = [[BWHXMASViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    BWHXMASViewConstraint *newConstraint = [[BWHXMASViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:BWHXMASViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        BWHXMASCompositeConstraint *compositeConstraint = [[BWHXMASCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (BWHXMASConstraint *)addConstraintWithAttributes:(MASAttribute)attrs {
    __unused MASAttribute anyAttribute = (MASAttributeLeft | MASAttributeRight | MASAttributeTop | MASAttributeBottom | MASAttributeLeading
                                          | MASAttributeTrailing | MASAttributeWidth | MASAttributeHeight | MASAttributeCenterX
                                          | MASAttributeCenterY | MASAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | MASAttributeFirstBaseline | MASAttributeLastBaseline
#endif
#if TARGET_OS_IPHONE || TARGET_OS_TV
                                          | MASAttributeLeftMargin | MASAttributeRightMargin | MASAttributeTopMargin | MASAttributeBottomMargin
                                          | MASAttributeLeadingMargin | MASAttributeTrailingMargin | MASAttributeCenterXWithinMargins
                                          | MASAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & MASAttributeLeft) [attributes addObject:self.view.mas_left];
    if (attrs & MASAttributeRight) [attributes addObject:self.view.mas_right];
    if (attrs & MASAttributeTop) [attributes addObject:self.view.mas_top];
    if (attrs & MASAttributeBottom) [attributes addObject:self.view.mas_bottom];
    if (attrs & MASAttributeLeading) [attributes addObject:self.view.mas_leading];
    if (attrs & MASAttributeTrailing) [attributes addObject:self.view.mas_trailing];
    if (attrs & MASAttributeWidth) [attributes addObject:self.view.mas_width];
    if (attrs & MASAttributeHeight) [attributes addObject:self.view.mas_height];
    if (attrs & MASAttributeCenterX) [attributes addObject:self.view.mas_centerX];
    if (attrs & MASAttributeCenterY) [attributes addObject:self.view.mas_centerY];
    if (attrs & MASAttributeBaseline) [attributes addObject:self.view.mas_baseline];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    if (attrs & MASAttributeFirstBaseline) [attributes addObject:self.view.mas_firstBaseline];
    if (attrs & MASAttributeLastBaseline) [attributes addObject:self.view.mas_lastBaseline];
    
#endif
    
#if TARGET_OS_IPHONE || TARGET_OS_TV
    
    if (attrs & MASAttributeLeftMargin) [attributes addObject:self.view.mas_leftMargin];
    if (attrs & MASAttributeRightMargin) [attributes addObject:self.view.mas_rightMargin];
    if (attrs & MASAttributeTopMargin) [attributes addObject:self.view.mas_topMargin];
    if (attrs & MASAttributeBottomMargin) [attributes addObject:self.view.mas_bottomMargin];
    if (attrs & MASAttributeLeadingMargin) [attributes addObject:self.view.mas_leadingMargin];
    if (attrs & MASAttributeTrailingMargin) [attributes addObject:self.view.mas_trailingMargin];
    if (attrs & MASAttributeCenterXWithinMargins) [attributes addObject:self.view.mas_centerXWithinMargins];
    if (attrs & MASAttributeCenterYWithinMargins) [attributes addObject:self.view.mas_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (BWHXMASViewAttribute *a in attributes) {
        [children addObject:[[BWHXMASViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    BWHXMASCompositeConstraint *constraint = [[BWHXMASCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (BWHXMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
}

- (BWHXMASConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (BWHXMASConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (BWHXMASConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (BWHXMASConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (BWHXMASConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (BWHXMASConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (BWHXMASConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (BWHXMASConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (BWHXMASConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (BWHXMASConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (BWHXMASConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (BWHXMASConstraint *(^)(MASAttribute))attributes {
    return ^(MASAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (BWHXMASConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}

- (BWHXMASConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif


#if TARGET_OS_IPHONE || TARGET_OS_TV

- (BWHXMASConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (BWHXMASConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (BWHXMASConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (BWHXMASConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (BWHXMASConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (BWHXMASConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (BWHXMASConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (BWHXMASConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif


#pragma mark - composite Attributes

- (BWHXMASConstraint *)edges {
    return [self addConstraintWithAttributes:MASAttributeTop | MASAttributeLeft | MASAttributeRight | MASAttributeBottom];
}

- (BWHXMASConstraint *)size {
    return [self addConstraintWithAttributes:MASAttributeWidth | MASAttributeHeight];
}

- (BWHXMASConstraint *)center {
    return [self addConstraintWithAttributes:MASAttributeCenterX | MASAttributeCenterY];
}

#pragma mark - grouping

- (BWHXMASConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        BWHXMASCompositeConstraint *constraint = [[BWHXMASCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
