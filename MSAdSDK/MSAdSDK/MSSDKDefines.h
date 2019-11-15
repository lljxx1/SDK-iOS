//
//  GDTSDKDefines.h
//  GDTMobApp
//
//  Created by royqpwang on 2017/11/6.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define MSWS(weakSelf) __weak __typeof(&*self)weakSelf = self;

// RGB颜色转换（16进制->10进制）
#define MSUIColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

typedef NS_ENUM(NSInteger, MSShowType) {
    MSShowTypeMS = 0, // 展示美数
    MSShowTypeGDT = 1, // 展示广点通
    MSShowTypeBU = 2, // 展示穿山甲
};

typedef NS_ENUM(NSInteger, MSOrientation) {
    MSOrientationPortrait = 0, // 展示竖屏
    MSOrientationLandscapeRight = 1, // 展示横屏
};


typedef NS_ENUM(NSInteger, MSNativeAdViewShowType) {
    MSLeftImage= 0, // 展示左图右文+下载按钮
    MSLeftImageNoButton = 1, // 展示左图右文
    MSBottomImage = 2, // 展示上文下大图
};

static NSString *kMSGDTMobSDKAppId = @"1105344611";

static NSString *kMSBUMobSDKAppId = @"5000546";


#define  BASIC_URL @"http://123.59.48.113/sdk/req_ad"
