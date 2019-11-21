//
//  BUSplashAdView+hit.m
//  Demo
//
//  Created by  xiaotu on 2019/11/14.
//  Copyright © 2019 bwhx. All rights reserved.
//

#import "BUSplashAdView+hit.h"



@implementation BUSplashAdView (hit)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
  return YES;
}
@end
