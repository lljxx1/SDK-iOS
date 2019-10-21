//
//  MSNativeAdView.h
//  MSAdSDK
//
//  Created by yang on 2019/8/30.
//  Copyright © 2019 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSAdModel.h"
#import "MSSDKDefines.h"

typedef void(^RequestMSAdData)(MSAdModel *adModel);                               // 请求头的数据


@class MSNativeAdView;

@protocol MSNativeAdDelegate <NSObject>

@optional

/**
 This method is called when native ad material loaded successfully.
 */
- (void)nativeAdDidLoad:(MSNativeAdView *)nativeAd;

/**
 This method is called when native ad materia failed to load.
 @param error : the reason of error
 */
- (void)nativeAd:(MSNativeAdView *)nativeAd didFailWithError:(NSError *)error;

/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(MSNativeAdView *)nativeAd;

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeAdDidCloseOtherController:(MSNativeAdView *)nativeAd;

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(MSNativeAdView *)nativeAd;

@end

@interface MSNativeAdView : UIView

/**
 *  委托对象
 */
@property (nonatomic, weak) id<MSNativeAdDelegate> delegate;

/**
 *  显示布局
 */
@property (assign, nonatomic)MSNativeAdViewShowType nativeAdViewShowType;


@property (strong, nonatomic)MSAdModel *adModel;

+ (void)requestMSAdData:(RequestMSAdData)msAdData;

/**
 *  构造方法
 *  详解：frame - banner 展示的位置和大小
 */
- (instancetype)initWithFrame:(CGRect)frame curController:(UIViewController*)controller;

+ (CGFloat)heightCellForRow:(MSAdModel*)adModel nativeAdViewShowType:(MSNativeAdViewShowType)nativeAdViewShowType;

@end
