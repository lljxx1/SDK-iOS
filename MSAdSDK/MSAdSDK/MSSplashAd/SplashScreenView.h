//
//  SplashScreenView.h
//  启动屏加启动广告页
//
//  Created by WOSHIPM on 16/8/9.
//  Copyright © 2016年 WOSHIPM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSAdModel.h"
static NSString *const adImageName = @"adImageName";
static NSString *const adUrl = @"adImageUrl";
static NSString *const adDeadline = @"adDeadline";

@class SplashScreenView;

@protocol MSAdDelegate <NSObject>

@optional
/**
 *  广告成功展示
 */
- (void)adSuccessPresentScreen:(SplashScreenView *)splashAd;

/**
 *  广告展示失败
 */
- (void)adFailToPresent:(SplashScreenView *)splashAd withError:(NSError *)error;

/**
 *  开屏广告点击回调
 */
- (void)adClicked:(SplashScreenView *)splashAd;

/**
 *  广告将要关闭回调
 */
- (void)adWillClosed:(SplashScreenView *)splashAd;

/**
 *  开屏广告关闭回调
 */
- (void)adClosed:(SplashScreenView *)splashAd;

/**
 *  banner广告点击以后弹出全屏广告页完毕
 */
- (void)bannerViewDidPresentFullScreenModal;

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)adDidDismissFullScreenModal:(SplashScreenView *)splashAd;

@end

@interface SplashScreenView : UIView
/**
 *  委托对象
 */
@property (nonatomic, weak) id<MSAdDelegate> delegate;

//开屏广告-半屏模式
- (instancetype)initWithFrame:(CGRect)frame adModel:(MSAdModel *)adModel adType:(NSInteger)adType bottomView:(UIView*)bottomView;
- (instancetype)initWithFrame:(CGRect)frame adModel:(MSAdModel*)adModel adType:(NSInteger)adType;

//美数实体
@property (nonatomic, strong) MSAdModel *adModel;

/** 广告类型*/
@property (nonatomic, assign) NSInteger adType;//0是开屏 1是banner  2s插屏

/** 广告图的显示时间*/
@property (nonatomic, assign) NSInteger ADShowTime;

/** 图片路径*/
@property (nonatomic, copy) NSString *imgFilePath;

/** 图片对应的url地址*/
@property (nonatomic, copy) NSString *imgLinkUrl;

/** 广告图的有效时间*/
@property (nonatomic, copy) NSString *imgDeadline;

/** 广告图*/
@property (nonatomic, strong) UIImageView *adImageView;

@property (nonatomic, strong)UIViewController *currentViewController;

/** 显示广告页面方法*/
- (void)showSplashScreenWithTime:(NSInteger)ADShowTime adType:(NSInteger)adType;

/**
 *  显示广告
 *  详解：显示广告
 */
- (void)showAd;

@end
