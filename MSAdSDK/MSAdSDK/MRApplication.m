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


@end

@implementation MRApplication

- (void)sendEvent:(UIEvent *)event{
    if (event.type==UIEventTypeTouches) {
        UITouch *touch = [event.allTouches anyObject];
        
        if (touch.phase == UITouchPhaseBegan) {
            UITouch *touch = [event.allTouches anyObject];
            CGPoint locationPointWindow = [touch preciseLocationInView:touch.window];
//            NSLog(@"began TouchLocationWindow:(%.1f,%.1f)",locationPointWindow.x,locationPointWindow.y);
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSString stringWithFormat:@"%.1f",locationPointWindow.x] forKey:@"x"];
            [dict setObject:[NSString stringWithFormat:@"%.1f",locationPointWindow.y] forKey:@"y"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MSUITouchPhaseBegan" object:dict];
        }
        
        if (touch.phase == UITouchPhaseMoved) {

        }
        
        if (touch.phase == UITouchPhaseEnded) {
            UITouch *touch = [event.allTouches anyObject];
            CGPoint locationPointWindow = [touch preciseLocationInView:touch.window];
//                NSLog(@"ended TouchLocationWindow:(%.1f,%.1f)",locationPointWindow.x,locationPointWindow.y);
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSString stringWithFormat:@"%.1f",locationPointWindow.x] forKey:@"x"];
            [dict setObject:[NSString stringWithFormat:@"%.1f",locationPointWindow.y] forKey:@"y"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MSUITouchPhaseEnded" object:dict];
            
        }
    }
    [super sendEvent:event];
}

@end
