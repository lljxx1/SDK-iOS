//
//  MSSplashAd.m
//  MSAdSDK
//
//  Created by yang on 2019/8/13.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSSplashAd.h"
#import "GDTSplashAd.h"
#import "GDTSDKConfig.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import "BUAdSDK/BUSplashAdView.h"
#import "MSSDKNetSession.h"
#import "SplashScreenView.h"
#import "SplashScreenDataManager.h"
#import "MSSDKModel.h"
@interface MSSplashAd()<GDTSplashAdDelegate,BUSplashAdDelegate,MSAdDelegate>
@property (strong, nonatomic) GDTSplashAd *splash;
@property (strong, nonatomic)BUSplashAdView *splashView;
@property (strong, nonatomic)SplashScreenView *advertiseView;
@property (assign, nonatomic)MSShowType showType;
@property (strong, nonatomic)NSMutableArray *dataArray;
@end

@implementation MSSplashAd
///**
// *  构造方法
// *  详解：appId - 广点通媒体 ID
// *       placementId - 广告位 ID
// */
//- (instancetype)initWithGDTAppId:(NSString *)GDTAppId placementId:(NSString *)GDTAppIdPlacementId withBUAppId:(NSString *)BUAppId withSlotID:(NSString *)slotID{
//    if(self = [super init]){
//        //初始化广点通
//        [self setGDTAppId:GDTAppId placementId:GDTAppIdPlacementId];
//        //初始化穿山甲
//        [self setBUAppId:BUAppId slotID:slotID];
//        self.showType = MSShowTypeMS;
//    }
//    return self;
//}
/**
 *  构造方法 如果不传入广点通或者穿山甲的AppId 就默认从美数服务器获取值
 */
- (instancetype)init{
    if(self = [super init]){
//        self.showType = MSShowTypeMS;
//        //初始化广点通
//        [self setGDTAppId:kMSGDTMobSDKAppId placementId:@"9040714184494018"];
//        //初始化穿山甲
//        [self setBUAppId:kMSBUMobSDKAppId slotID:@"800546808"];
//        //初始化美数
//        [self setMSAppId:kMSBUMobSDKAppId slotID:@"800546808"];
    }
    return self;
}
/**
 *  设置广点通方法
 *  详解：appId - 媒体 ID
 *       placementId - 广告位 ID
 */

- (void)setGDTAppId:(NSString *)GDTAppId placementId:(NSString *)GDTAppIdPlacementId{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        GDTSplashAd *splash = [[GDTSplashAd alloc] initWithAppId:GDTAppId placementId:GDTAppIdPlacementId];
        splash.delegate = self;
        UIImage *splashImage = [UIImage imageNamed:@"SplashNormal"];
        if (isIPhoneXSeries()) {
            splashImage = [UIImage imageNamed:@"SplashX"];
        } else if ([UIScreen mainScreen].bounds.size.height == 480) {
            splashImage = [UIImage imageNamed:@"SplashSmall"];
        }
        splash.backgroundImage = splashImage;
        splash.fetchDelay = 5;
        self.splash = splash;
    }
}

/**
 *  设置穿山甲方法
 *  详解：appId - 媒体 ID
 *       slotID - 广告位 ID
 */

- (void)setBUAppId:(NSString *)BUAppId slotID:(NSString *)slotID{
//#if DEBUG
//    //Whether to open log. default is none.
//    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
//#endif
    [BUAdSDKManager setAppID:BUAppId];
    [BUAdSDKManager setIsPaidApp:NO];
    CGRect frame = [UIScreen mainScreen].bounds;
    self.splashView = [[BUSplashAdView alloc] initWithSlotID:slotID frame:frame];
    self.splashView.delegate = self;
}

/**
 *  广告发起请求并展示在Window中
 *  详解：[可选]发起拉取广告请求,并将获取的广告以全屏形式展示在传入的Window参数中
 *  提示: Splash广告只支持竖屏
 *  @param window 展示全屏开屏的容器
 */
- (void)loadAdAndShowInWindow:(UIWindow *)window{
    MSWS(ws);
    NSMutableDictionary *dict = [MSCommCore publicParams];
    NSString *BundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [dict setObject:BundleId forKey:@"app_package"];
    [dict setObject:[MSAdSDK appId] forKey:@"app_id"];
    [dict setObject:@"1004462" forKey:@"pid"];
    __block MSAdModel *model = nil;
    ws.dataArray = [NSMutableArray array];

    [[MSSDKNetSession wsqflyNetWorkingShare]get:@"http://123.59.48.113/sdk/req_ad" param:dict maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
        if (response) {
            if ([response isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dict in response) {
                    if (dict) {
                        MSSDKModel *sdkModel = [MSSDKModel provinceWithDictionary:dict];
                        [ws.dataArray addObject:sdkModel];
                    }
                }
            }
            else{
                model = [MSAdModel provinceWithDictionary:response];
//                model.creative_type = 2;
                NSLog(@"%@", [NSString stringWithFormat:@"%ld",model.width]);
            }
        }
    } requestHead:^(id response) {
        NSLog(@"%@",response);
        if ([response[@"Response_type"] isEqualToString:@"API"]) {
            ws.advertiseView = [[SplashScreenView alloc] initWithFrame:[UIScreen mainScreen].bounds adType:0];
            ws.advertiseView.adModel = model;
            ws.advertiseView.delegate = ws;
            [self.advertiseView  showSplashScreenWithTime:5 adType:0];
        }
        else if ([response[@"Response_type"] isEqualToString:@"SDK"]) {
            if (ws.dataArray.count>0) {
                MSSDKModel *sdkModel = ws.dataArray[0];
                if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"GDT"]) {
                    [ws setGDTAppId:sdkModel.app_id placementId:sdkModel.pid];
                }
                else if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"CSJ"]){
                    [ws setBUAppId:sdkModel.app_id slotID:sdkModel.pid];
                }
            }
        }

    } faile:^(NSError *error) {
        if([ws.delegate respondsToSelector:@selector(splashAdFailToPresent:withError:)]){
            [ws.delegate splashAdFailToPresent:ws withError:error];
            [ws.advertiseView removeFromSuperview];
        }
    }];
    
    
//    //显示广点通
//    if(self.showType ==MSShowTypeGDT){
//        [self.splash loadAdAndShowInWindow:window];
//    }
//    //显示穿山甲
//    else if (self.showType == MSShowTypeBU){
//        [self.splashView loadAdData];
//        [window.rootViewController.view addSubview:self.splashView];
//        self.splashView.rootViewController = window.rootViewController;
//    }
//    else if (self.showType == MSShowTypeMS){
//        //        设置广告页显示的时间
//        [self.advertiseView  showSplashScreenWithTime:5];
//    }

}


#pragma mark - 这里是广点通的回调函数
/**
 *  开屏广告成功展示
 */
-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
    if([self.delegate respondsToSelector:@selector(splashAdSuccessPresentScreen:)]){
        [self.delegate splashAdSuccessPresentScreen:self];
    }
}
/**
 *  开屏广告展示失败
 */
-(void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(splashAdFailToPresent:withError:)]){
        [self.delegate splashAdFailToPresent:self withError:error];
    }
    self.splash = nil;
}

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(GDTSplashAd *)splashAd
{
    if([self.delegate respondsToSelector:@selector(splashAdWillClosed:)]){
        [self.delegate splashAdWillClosed:self];
    }
    self.splash = nil;
}
/**
 *  开屏广告关闭回调
 */
-(void)splashAdClosed:(GDTSplashAd *)splashAd
{
    if([self.delegate respondsToSelector:@selector(splashAdClosed:)]){
        [self.delegate splashAdClosed:self];
    }
    self.splash = nil;
}

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(GDTSplashAd *)splashAd
{
    if([self.delegate respondsToSelector:@selector(splashAdClicked:)]){
        [self.delegate splashAdClicked:self];
    }
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    if([self.delegate respondsToSelector:@selector(splashAdDidDismissFullScreenModal:)]){
        [self.delegate splashAdDidDismissFullScreenModal:self];
    }
}

#pragma mark - 这里是穿山甲的回调函数

/**
 This method is called when splash ad material loaded successfully.
 */
- (void)splashAdDidLoad:(BUSplashAdView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdSuccessPresentScreen:)]){
        [self.delegate splashAdSuccessPresentScreen:self];
    }
}

/**
 This method is called when splash ad material failed to load.
 @param error : the reason of error
 */
- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError * _Nullable)error{
    if([self.delegate respondsToSelector:@selector(splashAdWillClosed:)]){
        [self.delegate splashAdWillClosed:self];
    }
    [splashAd removeFromSuperview];
}
/**
 This method is called when splash ad slot will be showing.
 */
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd{
    
}

/**
 This method is called when splash ad is clicked.
 */
- (void)splashAdDidClick:(BUSplashAdView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdClicked:)]){
        [self.delegate splashAdClicked:self];
    }
}

/**
 This method is called when splash ad is closed.
 */
- (void)splashAdDidClose:(BUSplashAdView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdClosed:)]){
        [self.delegate splashAdClosed:self];
    }
    [splashAd removeFromSuperview];
}

/**
 This method is called when splash ad is about to close.
 */
- (void)splashAdWillClose:(BUSplashAdView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdWillClosed:)]){
        [self.delegate splashAdWillClosed:self];
    }
    [splashAd removeFromSuperview];
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)splashAdDidCloseOtherController:(BUSplashAdView *)splashAd interactionType:(BUInteractionType)interactionType{
    if([self.delegate respondsToSelector:@selector(splashAdDidDismissFullScreenModal:)]){
        [self.delegate splashAdDidDismissFullScreenModal:self];
    }
}


#pragma mark - 这里是美数的回调函数
/**
*  广告成功展示
*/
- (void)adSuccessPresentScreen:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdSuccessPresentScreen:)]){
        [self.delegate splashAdSuccessPresentScreen:self];
    }
    NSLog(@"美数回调成功");
}

/**
 *  广告展示失败
 */
//- (void)adFailToPresent:(SplashScreenView *)splashAd withError:(NSError *)error{
//    if([self.delegate respondsToSelector:@selector(splashAdWillClosed:)]){
//        [self.delegate splashAdWillClosed:self];
//    }
//    [splashAd removeFromSuperview];
//}

/**
*  开屏广告点击回调
*/
- (void)adClicked:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdClicked:)]){
        [self.delegate splashAdClicked:self];
    }
}

/**
 *  广告将要关闭回调
 */
- (void)adWillClosed:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdWillClosed:)]){
        [self.delegate splashAdWillClosed:self];
    }
    [splashAd removeFromSuperview];
}

/**
 *  开屏广告关闭回调
 */
- (void)adClosed:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdClosed:)]){
        [self.delegate splashAdClosed:self];
    }
    [splashAd removeFromSuperview];
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)adDidDismissFullScreenModal:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(splashAdDidDismissFullScreenModal:)]){
        [self.delegate splashAdDidDismissFullScreenModal:self];
    }
}


@end