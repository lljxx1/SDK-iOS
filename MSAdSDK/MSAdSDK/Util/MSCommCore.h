//
//  MSCommCore.h
//  MSAdSDK
//
//  Created by yang on 2019/8/23.
//  Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSCommCore : NSObject
//获取文本大小
+ (CGSize)getTextSize:(NSString *)message fontSize:(NSInteger)fontSize maxChatWidth:(NSInteger)maxChatWidth;

+ (UIImage *)imageNamed:(NSString *)name;

+ (NSString*)OpenUDID;

+ (NSMutableDictionary *)publicParams;
@end

NS_ASSUME_NONNULL_END
