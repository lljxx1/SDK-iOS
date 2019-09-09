//
//  NSArray+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+BWHXMASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface NSArray (BWHXMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(BWHXMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(BWHXMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(BWHXMASConstraintMaker *make))block;

@end

@implementation NSArray (BWHXMASShorthandAdditions)

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
