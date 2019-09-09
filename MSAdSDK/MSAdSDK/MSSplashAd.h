//
//  MSSplashAd.h
//  MSAdSDK
//  开屏广告
//  Created by yang on 2019/8/13.
//  Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSSplashAd;

@protocol MSSplashAdDelegate <NSObject>

@optional
/**
 *  开屏广告成功展示
 */
- (void)splashAdSuccessPresentScreen:(MSSplashAd *)splashAd;

/**
 *  开屏广告展示失败
 */
- (void)splashAdFailToPresent:(MSSplashAd *)splashAd withError:(NSError *)error;

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(MSSplashAd *)splashAd;

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(MSSplashAd *)splashAd;

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(MSSplashAd *)splashAd;

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(MSSplashAd *)splashAd;


@end

@interface MSSplashAd : NSObject

/**
 *  委托对象
 */
@property (nonatomic, weak) id<MSSplashAdDelegate> delegate;

/**
 *  拉取广告超时时间，默认为3秒
 *  详解：拉取广告超时时间，开发者调用loadAd方法以后会立即展示backgroundImage，然后在该超时时间内，如果广告拉
 *  取成功，则立马展示开屏广告，否则放弃此次广告展示机会。
 */
@property (nonatomic, assign) NSInteger fetchDelay;

/**
 *  广告发起请求并展示在Window中
 *  详解：[可选]发起拉取广告请求,并将获取的广告以全屏形式展示在传入的Window参数中
 *  提示: Splash广告只支持竖屏
 *  @param window 展示全屏开屏的容器
 */
- (void)loadAdAndShowInWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
