//
//  MSRewardVideoAd.m
//  MSAdSDK
//
//  Created by yang on 2019/8/18.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSRewardVideoAd.h"
#import "GDTRewardVideoAd.h"
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "SplashScreenView.h"
#import "SplashScreenDataManager.h"

@interface MSRewardVideoAd()<GDTRewardedVideoAdDelegate,BURewardedVideoAdDelegate>
@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;

@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (assign, nonatomic)MSShowType showType;
@property (nonatomic, strong)UIViewController *currentViewController;
@property (strong, nonatomic)NSMutableArray *dataArray;

@end

@implementation MSRewardVideoAd
/**
 *  构造方法 如果不传入广点通或者穿山甲的AppId 就默认从美数服务器获取值
 */
- (instancetype)initWithCurController:(UIViewController*)controller{
    if(self = [super init]){
        self.currentViewController = controller;
        self.showType = MSShowTypeGDT;
        //初始化广点通
        [self setGDTAppId:kMSGDTMobSDKAppId placementId:@"8020744212936426"];
        //初始化穿山甲
        [self setBUAppId:kMSBUMobSDKAppId slotID:@"900546826"];
        
    }
    return self;
}
/**
 *  设置广点通方法
 *  详解：appId - 媒体 ID
 *       placementId - 广告位 ID
 */
- (void)setGDTAppId:(NSString *)GDTAppId placementId:(NSString *)GDTAppIdPlacementId{
    self.rewardVideoAd = [[GDTRewardVideoAd alloc] initWithAppId:GDTAppId placementId:GDTAppIdPlacementId];
    self.rewardVideoAd.delegate = self;
    [self.rewardVideoAd loadAd];
}
- (void)setBUAppId:(NSString *)BUAppId slotID:(NSString *)slotID{
#warning Every time the data is requested, a new one BURewardedVideoAd needs to be initialized. Duplicate request data by the same full screen video ad is not allowed.
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = @"123";
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:slotID rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

/**
 *  显示广告
 *  详解：显示广告
 */
- (void)showAd{
    if (self.showType == MSShowTypeGDT) {
        [self.rewardVideoAd showAdFromRootViewController:self.currentViewController];
    }
    else if (self.showType == MSShowTypeBU){
        [self.rewardedVideoAd showAdFromRootViewController:self.currentViewController.navigationController ritScene:BURitSceneType_home_get_bonus ritSceneDescribe:nil];
    }
}

/**
 *  设置穿山甲方法
 *  详解：appId - 媒体 ID
 *       slotID - 广告位 ID
 */


/**
 广告数据加载成功回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidLoad:)]){
        [self.delegate rewardVideoAdDidLoad:self];
    }
}/**
  This method is called when video ad material loaded successfully.
  */
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidLoad:)]){
        [self.delegate rewardVideoAdDidLoad:self];
    }
}

/**
 视频数据下载成功回调，已经下载过的视频会直接回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdVideoDidLoad:)]){
        [self.delegate rewardVideoAdVideoDidLoad:self];
    }
}
/**
 This method is called when cached successfully.
 */
- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdVideoDidLoad:)]){
        [self.delegate rewardVideoAdVideoDidLoad:self];
    }
}
/**
 视频播放页即将展示回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdVideoDidLoad:)]){
        [self.delegate rewardVideoAdWillVisible:self];
    }
}
/**
 This method is called when video ad slot will be showing.
 */
- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdVideoDidLoad:)]){
        [self.delegate rewardVideoAdWillVisible:self];
    }
}

/**
 视频广告曝光回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidExposed:)]){
        [self.delegate rewardVideoAdDidExposed:self];
    }
}
/**
 This method is called when video ad slot has been shown.
 */
- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidExposed:)]){
        [self.delegate rewardVideoAdDidExposed:self];
    }
}

/**
 视频播放页关闭回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidClose:)]){
        [self.delegate rewardVideoAdDidClose:self];
    }
}
/**
 This method is called when video ad is closed.
 */
- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidClose:)]){
        [self.delegate rewardVideoAdDidClose:self];
    }
}

/**
 视频广告信息点击回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidClicked:)]){
        [self.delegate rewardVideoAdDidClicked:self];
    }
}

/**
 This method is called when video ad is clicked.
 */
- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidClicked:)]){
        [self.delegate rewardVideoAdDidClicked:self];
    }
}

/**
 视频广告各种错误信息回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(rewardVideoAd: didFailWithError:)]){
        [self.delegate rewardVideoAd:self didFailWithError:error];
    }
}
/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error{
    if([self.delegate respondsToSelector:@selector(rewardVideoAd: didFailWithError:)]){
        [self.delegate rewardVideoAd:self didFailWithError:error];
    }
}

/**
 视频广告播放达到激励条件回调
 @param rewardedVideoAdP GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAdP{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidRewardEffective:)]){
        [self.delegate rewardVideoAdDidRewardEffective:self];
    }
}
/**
 Server verification which is requested asynchronously is succeeded.
 @param verify :return YES when return value is 2000.
 */
- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    if (verify) {
        if([self.delegate respondsToSelector:@selector(rewardVideoAdDidRewardEffective:)]){
            [self.delegate rewardVideoAdDidRewardEffective:self];
        }
    }
}

/**
 视频广告视频播放完成
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidPlayFinish:)]){
        [self.delegate rewardVideoAdDidPlayFinish:self];
    }
}

/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error{
    if (!error) {
        if([self.delegate respondsToSelector:@selector(rewardVideoAdDidPlayFinish:)]){
            [self.delegate rewardVideoAdDidPlayFinish:self];
        }
    }
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidPlayFinish:)]){
        [self.delegate rewardVideoAdDidPlayFinish:self];
    }
}
@end