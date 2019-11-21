//
//  MASConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "BWHXMASUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (MASViewConstraint) 
 *  or a group of NSLayoutConstraints (MASComposisteConstraint)
 */
@interface BWHXMASConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (BWHXMASConstraint * (^)(MASEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (BWHXMASConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (BWHXMASConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (BWHXMASConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (BWHXMASConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (BWHXMASConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (BWHXMASConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or MASLayoutPriority
 */
- (BWHXMASConstraint * (^)(MASLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityLow
 */
- (BWHXMASConstraint * (^)())priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityMedium
 */
- (BWHXMASConstraint * (^)())priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to MASLayoutPriorityHigh
 */
- (BWHXMASConstraint * (^)())priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (BWHXMASConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (BWHXMASConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (BWHXMASConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (BWHXMASConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (BWHXMASConstraint *)and;

/**
 *	Creates a new MASCompositeConstraint with the called attribute and reciever
 */
- (BWHXMASConstraint *)left;
- (BWHXMASConstraint *)top;
- (BWHXMASConstraint *)right;
- (BWHXMASConstraint *)bottom;
- (BWHXMASConstraint *)leading;
- (BWHXMASConstraint *)trailing;
- (BWHXMASConstraint *)width;
- (BWHXMASConstraint *)height;
- (BWHXMASConstraint *)centerX;
- (BWHXMASConstraint *)centerY;
- (BWHXMASConstraint *)baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (BWHXMASConstraint *)firstBaseline;
- (BWHXMASConstraint *)lastBaseline;

#endif

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (BWHXMASConstraint *)leftMargin;
- (BWHXMASConstraint *)rightMargin;
- (BWHXMASConstraint *)topMargin;
- (BWHXMASConstraint *)bottomMargin;
- (BWHXMASConstraint *)leadingMargin;
- (BWHXMASConstraint *)trailingMargin;
- (BWHXMASConstraint *)centerXWithinMargins;
- (BWHXMASConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (BWHXMASConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of mas_updateConstraints/mas_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(MASEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;


// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) MASConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end


/**
 *  Convenience auto-boxing macros for MASConstraint methods.
 *
 *  Defining MAS_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define mas_equalTo(...)                 equalTo(MASBoxValue((__VA_ARGS__)))
#define mas_greaterThanOrEqualTo(...)    greaterThanOrEqualTo(MASBoxValue((__VA_ARGS__)))
#define mas_lessThanOrEqualTo(...)       lessThanOrEqualTo(MASBoxValue((__VA_ARGS__)))

#define mas_offset(...)                  valueOffset(MASBoxValue((__VA_ARGS__)))


#ifdef MAS_SHORTHAND_GLOBALS

#define equalTo(...)                     mas_equalTo(__VA_ARGS__)
#define greaterThanOrEqualTo(...)        mas_greaterThanOrEqualTo(__VA_ARGS__)
#define lessThanOrEqualTo(...)           mas_lessThanOrEqualTo(__VA_ARGS__)

#define offset(...)                      mas_offset(__VA_ARGS__)

#endif


@interface BWHXMASConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (BWHXMASConstraint * (^)(id attr))mas_equalTo;
- (BWHXMASConstraint * (^)(id attr))mas_greaterThanOrEqualTo;
- (BWHXMASConstraint * (^)(id attr))mas_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (BWHXMASConstraint * (^)(id offset))mas_offset;

@end
