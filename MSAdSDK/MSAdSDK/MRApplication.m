//
//  MRApplication.m
//  MSAdSDK
//
//  Created by yang on 2019/10/21.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MRApplication.h"
#include <CommonCrypto/CommonCrypto.h>

@interface MRApplication()

@property(nonatomic,assign) BOOL isMoved;

@end

@implementation MRApplication

- (void)sendEvent:(UIEvent *)event{
    if (event.type==UIEventTypeTouches) {
        UITouch *touch = [event.allTouches anyObject];
        
        if (touch.phase == UITouchPhaseBegan) {
//            self.isMoved = NO;
            UITouch *touch = [event.allTouches anyObject];
            CGPoint locationPointWindow = [touch preciseLocationInView:touch.window];
            NSLog(@"began TouchLocationWindow:(%.1f,%.1f)",locationPointWindow.x,locationPointWindow.y);
        }
        
        if (touch.phase == UITouchPhaseMoved) {
//            self.isMoved = YES;
        }
        
        if (touch.phase == UITouchPhaseEnded) {
//            if (!self.isMoved && event.allTouches.count == 1) {
                UITouch *touch = [event.allTouches anyObject];
                CGPoint locationPointWindow = [touch preciseLocationInView:touch.window];
                NSLog(@"ended TouchLocationWindow:(%.1f,%.1f)",locationPointWindow.x,locationPointWindow.y);
//            }
//            self.isMoved = NO;
        }
    }
    [super sendEvent:event];
}

@end
