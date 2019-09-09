//
//  MSAdSDK.m
//  MSAdSDK
//
//  Created by yang on 2019/8/5.
//  Copyright © 2019年 yang. All rights reserved.
//

#import "MSAdSDK.h"
static NSString *const MSAppId = @"MSAppId";

@implementation MSAdSDK
+ (void)setAppId:(NSString *)appId{
    if (appId) {
        [[NSUserDefaults standardUserDefaults] setValue:appId forKey:MSAppId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSString *)appId{
    NSString *appId = [[NSUserDefaults standardUserDefaults] valueForKey:MSAppId];
    return appId;
}
@end

