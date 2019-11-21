//
//  UIViewController+MASAdditions.m
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+BWHXMASAdditions.h"

#ifdef MAS_VIEW_CONTROLLER

@implementation MAS_VIEW_CONTROLLER (BWHXMASAdditions)

- (BWHXMASViewAttribute *)mas_topLayoutGuide {
    return [[BWHXMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (BWHXMASViewAttribute *)mas_topLayoutGuideTop {
    return [[BWHXMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (BWHXMASViewAttribute *)mas_topLayoutGuideBottom {
    return [[BWHXMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (BWHXMASViewAttribute *)mas_bottomLayoutGuide {
    return [[BWHXMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (BWHXMASViewAttribute *)mas_bottomLayoutGuideTop {
    return [[BWHXMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (BWHXMASViewAttribute *)mas_bottomLayoutGuideBottom {
    return [[BWHXMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
