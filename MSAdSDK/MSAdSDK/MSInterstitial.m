//
//  MSInterstitial.m
//  MSAdSDK
//
//  Created by yang on 2019/8/18.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSInterstitial.h"
#import "GDTMobInterstitial.h"
#import <BUAdSDK/BUInterstitialAd.h>
#import <BUAdSDK/BUSize.h>
#import "SplashScreenView.h"
#import "SplashScreenDataManager.h"
#import "MSSDKModel.h"
@interface MSInterstitial()<GDTMobInterstitialDelegate,BUInterstitialAdDelegate,MSAdDelegate>
@property (nonatomic, strong) GDTMobInterstitial *interstitial;
@property (nonatomic, strong) BUInterstitialAd *interstitialAd;
@property (strong, nonatomic)SplashScreenView *advertiseView;
@property (assign, nonatomic)MSShowType showType;
@property (nonatomic, strong)UIViewController *currentViewController;
@property (strong, nonatomic)NSMutableArray *dataArray;

@end

@implementation MSInterstitial


/**
 *  构造方法 如果不传入广点通或者穿山甲的AppId 就默认从美数服务器获取值
 */
- (instancetype)initWithCurController:(UIViewController*)controller{
    if(self = [super init]){
//        self.currentViewController = controller;
//        self.showType = MSShowTypeMS;
//        if (self.showType == MSShowTypeGDT){
//            //初始化广点通
//            [self setGDTAppId:kMSGDTMobSDKAppId placementId:@"2030814134092814"];
//        }
//        else if (self.showType == MSShowTypeBU){
//            //初始化穿山甲
//            [self setBUAppId:kMSBUMobSDKAppId slotID:@"900546941"];
//        }
//        else if (self.showType == MSShowTypeMS){
//            [self setMSFrame:CGRectMake(([UIScreen mainScreen].bounds.size.height-200)/2, ([UIScreen mainScreen].bounds.size.height-300)/2, 200, 300) appId:kMSBUMobSDKAppId slotID:@"900546859"];
//        }
//
        
        MSWS(ws);
        NSMutableDictionary *dict = [MSCommCore publicParams];
        NSString *BundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        [dict setObject:BundleId forKey:@"app_package"];
        [dict setObject:[MSAdSDK appId] forKey:@"app_id"];
        [dict setObject:@"1004464" forKey:@"pid"];
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
                    NSLog(@"%@", [NSString stringWithFormat:@"%ld",model.width]);
                }
            }
   
            
        } requestHead:^(id response) {
            if ([response[@"Response_type"] isEqualToString:@"API"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                    ws.advertiseView = [[SplashScreenView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2, ([UIScreen mainScreen].bounds.size.height-300)/2, 200, 300) adType:2];
                    ws.advertiseView.adModel = model;
                    ws.advertiseView.delegate = ws;
                    if([self.delegate respondsToSelector:@selector(interstitialSuccessToLoadAd:)]){
                        [self.delegate interstitialSuccessToLoadAd:self];
                    }
                });
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
            if([ws.delegate respondsToSelector:@selector(interstitialFailToLoadAd:error:)]){
                [ws.delegate interstitialFailToLoadAd:ws error:error];
            }
        }];
    }
    return self;
}
/**
 *  设置广点通方法
 *  详解：appId - 媒体 ID
 *       placementId - 广告位 ID
 */
- (void)setGDTAppId:(NSString *)GDTAppId placementId:(NSString *)GDTAppIdPlacementId{
    if(self.interstitial) {
        self.interstitial.delegate = nil;
    }
    self.interstitial = [[GDTMobInterstitial alloc] initWithAppId:GDTAppId placementId:GDTAppIdPlacementId];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

/**
 *  显示广告
 *  详解：显示广告
 */
- (void)showAd{
//    if (self.showType == MSShowTypeGDT) {
//        [self.interstitial presentFromRootViewController:self.currentViewController];
//    }
//    else if (self.showType == MSShowTypeBU){
//        [self.interstitialAd showAdFromRootViewController:self.currentViewController.navigationController];
//    }
//    else if (self.showType == MSShowTypeMS){
//        [self.advertiseView showAd];
//    }
    [self.advertiseView  showSplashScreenWithTime:0 adType:2];

}

/**
 *  设置穿山甲方法
 *  详解：appId - 媒体 ID
 *       slotID - 广告位 ID
 */

- (void)setBUAppId:(NSString *)BUAppId slotID:(NSString *)slotID{
    self.interstitialAd = [[BUInterstitialAd alloc] initWithSlotID:slotID size:[BUSize sizeBy:BUProposalSize_Interstitial600_600]];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAdData];
}

/**
 *  设置美数方法
 *  详解：appId - 媒体 ID
 *       slotID - 广告位 ID
 */

- (void)setMSFrame:(CGRect)frame  appId:(NSString *)BUAppId slotID:(NSString *)slotID{
    // 1.判断沙盒中是否存在广告图片
    MSWS(ws);
    NSString *filePath = [SplashScreenDataManager getFilePathWithImageName:[[NSUserDefaults standardUserDefaults] valueForKey:adImageName]];
    // 图片存在
    ws.advertiseView = [[SplashScreenView alloc] initWithFrame:frame adType:2];
    ws.advertiseView.currentViewController = ws.currentViewController;
    ws.advertiseView .imgFilePath = filePath;
    ws.advertiseView .imgLinkUrl = [[NSUserDefaults standardUserDefaults] valueForKey:adUrl];
    ws.advertiseView .imgDeadline = [[NSUserDefaults standardUserDefaults] valueForKey:adDeadline];
    [SplashScreenDataManager getAdvertisingImageDataImageWithUrl:@"http://pic27.nipic.com/20130315/11511914_151013608193_2.jpg" imgLinkUrl:@"https://www.baidu.com" success:^(id data) {
        ws.advertiseView.adImageView.image = data;
        
    } fail:^(NSError *error) {
        
    }];
}

/**
 *  广告预加载成功回调
 *  详解:当接收服务器返回的广告数据成功且预加载后调用该函数
 */
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial{
    if([self.delegate respondsToSelector:@selector(interstitialSuccessToLoadAd:)]){
        [self.delegate interstitialSuccessToLoadAd:self];
    }
}
/**
 This method is called when interstitial ad material loaded successfully.
 */
- (void)interstitialAdDidLoad:(BUInterstitialAd *)interstitialAd{
    if([self.delegate respondsToSelector:@selector(interstitialSuccessToLoadAd:)]){
        [self.delegate interstitialSuccessToLoadAd:self];
    }
}

/**
 *  广告预加载失败回调
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(interstitialFailToLoadAd:error:)]){
        [self.delegate interstitialFailToLoadAd:self error:error];
    }
}
/**
 This method is called when interstitial ad material failed to load.
 @param error : the reason of error
 */
- (void)interstitialAd:(BUInterstitialAd *)interstitialAd didFailWithError:(NSError * _Nullable)error{
    if([self.delegate respondsToSelector:@selector(interstitialFailToLoadAd:error:)]){
        [self.delegate interstitialFailToLoadAd:self error:error];
    }
}

/**
 *  插屏广告视图展示成功回调
 *  详解: 插屏广告展示成功回调该函数
 */
- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial{
    if([self.delegate respondsToSelector:@selector(interstitialDidPresentScreen:)]){
        [self.delegate interstitialDidPresentScreen:self];
    }
}

/**
 This method is called when interstitial ad slot will be showing.
 */
- (void)interstitialAdWillVisible:(BUInterstitialAd *)interstitialAd{
    if([self.delegate respondsToSelector:@selector(interstitialDidPresentScreen:)]){
        [self.delegate interstitialDidPresentScreen:self];
    }
}
/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)interstitialDidDismissScreen:(MSInterstitial *)interstitial{
    if([self.delegate respondsToSelector:@selector(interstitialDidDismissScreen:)]){
        [self.delegate interstitialDidDismissScreen:self];
    }
}
/**
 This method is called when interstitial ad is closed.
 */
- (void)interstitialAdDidClose:(BUInterstitialAd *)interstitialAd{
    if([self.delegate respondsToSelector:@selector(interstitialAdDidClose:)]){
        [self.delegate interstitialDidDismissScreen:self];
    }
}

/**
 *  插屏广告点击回调
 */
- (void)interstitialClicked:(GDTMobInterstitial *)interstitial{
    if([self.delegate respondsToSelector:@selector(interstitialClicked:)]){
        [self.delegate interstitialClicked:self];
    }
}
/**
 This method is called when interstitial ad is clicked.
 */
- (void)interstitialAdDidClick:(BUInterstitialAd *)interstitialAd{
    if([self.delegate respondsToSelector:@selector(interstitialClicked:)]){
        [self.delegate interstitialClicked:self];
    }
}

/**
 *  全屏广告页被关闭
 */
- (void)interstitialAdDidDismissFullScreenModal:(GDTMobInterstitial *)interstitial{
    if([self.delegate respondsToSelector:@selector(interstitialAdDidDismissFullScreenModal:)]){
        [self.delegate interstitialAdDidDismissFullScreenModal:self];
    }
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)interstitialAdDidCloseOtherController:(BUInterstitialAd *)interstitialAd interactionType:(BUInteractionType)interactionType{
    if([self.delegate respondsToSelector:@selector(interstitialAdDidDismissFullScreenModal:)]){
        [self.delegate interstitialAdDidDismissFullScreenModal:self];
    }
}



#pragma mark - 这里是美数的回调函数
/**
 *  广告成功展示
 */
- (void)adSuccessPresentScreen:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(interstitialSuccessToLoadAd:)]){
        [self.delegate interstitialSuccessToLoadAd:self];
    }
    NSLog(@"美数回调成功");
}

/**
 *  广告展示失败
 */
- (void)adFailToPresent:(SplashScreenView *)splashAd withError:(NSError *)error{
    if([self.delegate respondsToSelector:@selector(interstitialFailToLoadAd:error:)]){
        [self.delegate interstitialFailToLoadAd:self error:error];
    }
//    [splashAd removeFromSuperview];
}

/**
 *  广告点击回调
 */
- (void)adClicked:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(interstitialClicked:)]){
        [self.delegate interstitialClicked:self];
    }
}



/**
 *  广告将要关闭回调
 */
- (void)adWillClosed:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(interstitialDidDismissScreen:)]){
        [self.delegate interstitialDidDismissScreen:self];
    }
//    [splashAd removeFromSuperview];
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)adDidDismissFullScreenModal:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(interstitialAdDidDismissFullScreenModal:)]){
        [self.delegate interstitialAdDidDismissFullScreenModal:self];
    }
//    [splashAd removeFromSuperview];

}


@end