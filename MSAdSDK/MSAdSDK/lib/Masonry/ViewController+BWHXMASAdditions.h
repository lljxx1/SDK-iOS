//
//  UIViewController+MASAdditions.h
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "BWHXMASUtilities.h"
#import "BWHXMASConstraintMaker.h"
#import "BWHXMASViewAttribute.h"

#ifdef MAS_VIEW_CONTROLLER

@interface MAS_VIEW_CONTROLLER (BWHXMASAdditions)

/**
 *	following properties return a new MASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *mas_topLayoutGuide;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *mas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *mas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *mas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *mas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) BWHXMASViewAttribute *mas_bottomLayoutGuideBottom;


@end

#endif
