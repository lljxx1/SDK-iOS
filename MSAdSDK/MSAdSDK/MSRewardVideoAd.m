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
#import <BUAdSDK/BUAdSDKManager.h>
@interface MSRewardVideoAd()<GDTRewardedVideoAdDelegate,BURewardedVideoAdDelegate,MSAdDelegate>
@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (strong, nonatomic)SplashScreenView *advertiseView;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (assign, nonatomic)MSShowType showType;
@property (nonatomic, strong)UIViewController *currentViewController;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (strong, nonatomic)MSAdModel *msAdModel;

@property (strong, nonatomic)NSMutableDictionary *beganDict;


@end

@implementation MSRewardVideoAd
/**
 *  构造方法 如果不传入广点通或者穿山甲的AppId 就默认从美数服务器获取值
 */
- (instancetype)initWithCurController:(UIViewController*)controller{
    if(self = [super init]){
        self.currentViewController = controller;
        self.showType = MSShowTypeBU;
        //初始化广点通
        [self setGDTAppId:kMSGDTMobSDKAppId placementId:@"8020744212936426"];
        //初始化穿山甲
        [self setBUAppId:kMSBUMobSDKAppId slotID:@"900546826"];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getMSUITouchPhaseBegan:) name:@"MSUITouchPhaseBegan" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getUITouchPhaseEnded:) name:@"MSUITouchPhaseEnded" object:nil];
        
    }
    return self;
}

//获取视图上点击的起始点
- (void)getMSUITouchPhaseBegan:(NSNotification*)notification{
    MSWS(ws);
    ws.beganDict = notification.object;
}

//获取视图上点击的终止点
- (void)getUITouchPhaseEnded:(NSNotification*)notification{
    MSWS(ws);
    NSMutableDictionary *dict = notification.object;
    
    if(ws.msAdModel.dUrl.count>0){
        NSString *dUrl = ws.msAdModel.dUrl[0];
        //这里是测试界面点击后坐标的替换 然后上报
        //        NSString *dUrl = @"http://cuxiao.suning.com/newUser.html?safp=d488778a.homepage1.ViRgl.7&safc=cuxiao.0.0&dx=__DOWN_X__&dy=__DOWN_Y__&ux=__UP_X__&uy=__UP_Y__&cid=__CLICK_ID__&es=__MS_EVENT_SEC__&ems=__MS_EVENT_MSEC__";
        dUrl = [dUrl stringByReplacingOccurrencesOfString:@"__DOWN_X__" withString:ws.beganDict[@"x"]];
        dUrl = [dUrl stringByReplacingOccurrencesOfString:@"__DOWN_Y__" withString:ws.beganDict[@"y"]];
        dUrl = [dUrl stringByReplacingOccurrencesOfString:@"__UP_X__" withString:dict[@"x"]];
        dUrl = [dUrl stringByReplacingOccurrencesOfString:@"__UP_Y__" withString:dict[@"y"]];
        
        [[MSSDKNetSession wsqflyNetWorkingShare]get:dUrl param:nil maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
            
        } requestHead:^(id response) {
            
        } faile:^(NSError *error) {
            
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MSUITouchPhaseBegan" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MSUITouchPhaseEnded" object:nil];
    
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
    [BUAdSDKManager setAppID:BUAppId];

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
//    if (self.showType == MSShowTypeGDT) {
//        [self.rewardVideoAd showAdFromRootViewController:self.currentViewController];
//    }
//    else if (self.showType == MSShowTypeBU){
//        [self.rewardedVideoAd showAdFromRootViewController:self.currentViewController.navigationController ritScene:BURitSceneType_custom ritSceneDescribe:nil];
//    }
    
    
    MSWS(ws);
    NSMutableDictionary *dict = [MSCommCore publicParams];
    NSString *BundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [dict setObject:BundleId forKey:@"app_package"];
    [dict setObject:[MSAdSDK appId] forKey:@"app_id"];
    [dict setObject:@"1004462" forKey:@"pid"];
    __block MSAdModel *model = nil;
    
    [[MSSDKNetSession wsqflyNetWorkingShare]get:@"http://123.59.48.113/sdk/req_ad" param:dict maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
        if (response) {
            model = [MSAdModel provinceWithDictionary:response];
            model.creative_type = 2;
            NSLog(@"%@", [NSString stringWithFormat:@"%ld",model.width]);
            ws.msAdModel = model;
        }
    } requestHead:^(id response) {
        NSLog(@"%@",response);
        //我们假设一个场景，广告的调用顺序是：1. 广点通；2.穿山甲；3.打底广告；
        if (model) {
            if(model.sdk.count>0){
                    MSSDKModel *sdkModel = model.sdk[0];
                    if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"GDT"]) {
                        [ws setGDTAppId:sdkModel.app_id placementId:sdkModel.pid];
                    }
                    else if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"CSJ"]){
                        [ws setBUAppId:sdkModel.app_id slotID:sdkModel.pid];
                    }
            }
            else{//如果都没有 广点通和穿山甲的广告 那就显示美数广告
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //数据曝光即是数据加载完成后上报
                    if(model&&model.monitorUrl.count>0){
                        NSString *monitorUrl = model.monitorUrl[0];
                        [[MSSDKNetSession wsqflyNetWorkingShare]get:monitorUrl param:nil maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
                            
                        } requestHead:^(id response) {
                            
                        } faile:^(NSError *error) {
                            
                        }];
                    }
                    
                    ws.advertiseView = [[SplashScreenView alloc] initWithFrame:[UIScreen mainScreen].bounds adModel:model  adType:0];
                    ws.advertiseView.adModel = model;
                    ws.advertiseView.delegate = ws;
                    [ws.advertiseView  showSplashScreenWithTime:5 adType:3];
                });
            }
        }
    } faile:^(NSError *error) {
        
    }];
    
    
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
   
    MSWS(ws);
    //如果广点通调用失败后，还有穿山甲的广告，继续调用，不回调失败
    if (ws.msAdModel.sdk.count==2) {
        MSSDKModel *sdkModel = ws.msAdModel.sdk[1];
        //调用穿山甲SDK
        if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"CSJ"]){
            [ws setBUAppId:sdkModel.app_id slotID:sdkModel.pid];
            return;
        }
    }
    
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

#pragma mark - 这里是美数的回调函数
/**
 *  广告成功展示
 */
- (void)adSuccessPresentScreen:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidLoad:)]){
        [self.delegate rewardVideoAdDidLoad:self];
    }
    NSLog(@"美数回调成功");
}

/**
 *  广告展示失败
 */
- (void)adFailToPresent:(SplashScreenView *)splashAd withError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(rewardVideoAd:didFailWithError:)]){
        [self.delegate rewardVideoAd:self didFailWithError:error];
    }
    //    [splashAd removeFromSuperview];
}

/**
 *  广告点击回调
 */
- (void)adClicked:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidClicked:)]){
        [self.delegate rewardVideoAdDidClicked:self];
    }
}



/**
 *  广告将要关闭回调
 */
- (void)adWillClosed:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidClose:)]){
        [self.delegate rewardVideoAdDidClose:self];
    }
    //    [splashAd removeFromSuperview];
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)adDidDismissFullScreenModal:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(rewardVideoAdDidPlayFinish:)]){
        [self.delegate rewardVideoAdDidPlayFinish:self];
    }
    //    [splashAd removeFromSuperview];
    
}

@end
