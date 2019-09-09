//
//  MSBannerView.m
//  MSAdSDK
//
//  Created by yang on 2019/8/16.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSBannerView.h"
#import "GDTMobBannerView.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import <BUAdSDK/BUBannerAdView.h>
#import "SplashScreenView.h"
#import "SplashScreenDataManager.h"
#import "MSSDKModel.h"

@interface MSBannerView()<GDTMobBannerViewDelegate,BUBannerAdViewDelegate,MSAdDelegate>
//广点通
@property (nonatomic, strong) GDTMobBannerView *bannerView;
//穿山甲
@property(nonatomic, strong) BUBannerAdView *buBannerView;

@property (strong, nonatomic)SplashScreenView *advertiseView;

@property (nonatomic, strong)UIViewController *currentViewController;

@property (assign, nonatomic)MSShowType showType;

@property (strong, nonatomic)NSMutableArray *dataArray;

@end

@implementation MSBannerView


///**
// *  构造方法
// *  详解：appId - 媒体 ID
// *       placementId - 广告位 ID
// */
//- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId
//{
//    if (self =[super initWithFrame:CGRectZero]) {
//        CGRect frame = {CGPointZero, GDTMOB_AD_SUGGEST_SIZE_320x50};
//        self.frame = frame;
//        [self setGDTFrame:frame appId:appId placementId:placementId];
//    }
//    return self;
//}
//
///**
// *  构造方法
// *  详解：frame - banner 展示的位置和大小
// *       appId - 媒体 ID
// *       placementId - 广告位 ID
// */
//
//- (instancetype)initWithFrame:(CGRect)frame appId:(NSString *)appId placementId:(NSString *)placementId{
//    if (self = [super initWithFrame:frame]) {
//        self.frame = frame;
//        [self setGDTFrame:frame appId:appId placementId:placementId];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame curController:(UIViewController*)controller{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
//        self.currentViewController = controller;
//        self.showType = MSShowTypeMS;
//        if (self.showType == MSShowTypeGDT) {
//            [self setGDTFrame:frame appId:kMSGDTMobSDKAppId placementId:@"4090812164690039"];
//        }
//        else if (self.showType == MSShowTypeBU){
//            [self setBUFrame:frame appId:kMSBUMobSDKAppId slotID:@"900546859"];
//        }
//        else if (self.showType == MSShowTypeMS){
//            [self setMSFrame:frame appId:kMSBUMobSDKAppId slotID:@"900546859"];
//        }
    }
    return self;
}

/**
 *  拉取并展示广告
 */
- (void)loadAdAndShow{
    
    MSWS(ws);
    NSMutableDictionary *dict = [MSCommCore publicParams];
    NSString *BundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [dict setObject:BundleId forKey:@"app_package"];
    [dict setObject:[MSAdSDK appId] forKey:@"app_id"];
    [dict setObject:@"1004463" forKey:@"pid"];
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
                ws.advertiseView = [[SplashScreenView alloc] initWithFrame:ws.frame adType:1];
                ws.advertiseView.adModel = model;
                ws.advertiseView.delegate = ws;
                [ws.advertiseView  showSplashScreenWithTime:0 adType:1];
                [ws addSubview:ws.advertiseView];
            });
        }
        else if ([response[@"Response_type"] isEqualToString:@"SDK"]) {
            if (ws.dataArray.count>0) {
                MSSDKModel *sdkModel = ws.dataArray[0];
                if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"GDT"]) {
                    [ws setGDTFrame:ws.frame appId:sdkModel.app_id  placementId:sdkModel.pid];
                }
                else if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"CSJ"]){
                    [ws setBUFrame:ws.frame appId:sdkModel.app_id  slotID:sdkModel.pid];
                }
            }
        }
    } faile:^(NSError *error) {
        if([ws.delegate respondsToSelector:@selector(bannerViewFailToReceived:)]){
            [ws.delegate bannerViewFailToReceived:error];
            [ws.advertiseView removeFromSuperview];
        }
    }];
    
//    if (self.showType == MSShowTypeGDT) {
//        [self.bannerView loadAdAndShow];
//    }
//    else if (self.showType == MSShowTypeBU){
//        [self.buBannerView loadAdData];
//    }
//    else if (self.showType == MSShowTypeMS){
//
//    }
    
}

/**
 *  设置广点通方法
 *  详解：appId - 媒体 ID
 *       placementId - 广告位 ID
 */

- (void)setGDTFrame:(CGRect)frame appId:(NSString *)GDTAppId placementId:(NSString *)GDTAppIdPlacementId{
    GDTMobBannerView *bannerView = [[GDTMobBannerView alloc] initWithFrame:frame appId:GDTAppId placementId:GDTAppIdPlacementId];
    bannerView.accessibilityIdentifier = @"banner_ad";
    bannerView.currentViewController = self.currentViewController;
//    广告刷新间隔
    bannerView.interval = 30;
    bannerView.isAnimationOn = YES;
    bannerView.showCloseBtn = YES;
//    GPS精准广告定位模式开关,默认Gps关闭
    bannerView.isGpsOn = NO;
    bannerView.delegate = self;
    self.bannerView = bannerView;
    [self addSubview:self.bannerView];
}

/**
 *  设置穿山甲方法
 *  详解：appId - 媒体 ID
 *       slotID - 广告位 ID
 */

- (void)setBUFrame:(CGRect)frame appId:(NSString *)BUAppId slotID:(NSString *)slotID{
    BUSize *size = [BUSize sizeBy:BUProposalSize_Banner600_150];
    size.width = frame.size.width;
    size.height = frame.size.height;
    self.buBannerView = [[BUBannerAdView alloc] initWithSlotID:slotID size:size rootViewController:self.currentViewController];
    const CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    CGFloat bannerHeight = screenWidth * size.height / size.width;
    self.buBannerView.frame = CGRectMake(0, 0, screenWidth, bannerHeight);
    self.buBannerView.delegate = self;
    [self addSubview:self.buBannerView];
}

/**
 *  设置美数方法
 *  详解：appId - 媒体 ID
 *       slotID - 广告位 ID
 */

- (void)setMSFrame:(CGRect)frame  appId:(NSString *)BUAppId slotID:(NSString *)slotID{
    MSWS(ws);
    NSString *filePath = [SplashScreenDataManager getFilePathWithImageName:[[NSUserDefaults standardUserDefaults] valueForKey:adImageName]];
    // 图片存在
    ws.advertiseView = [[SplashScreenView alloc] initWithFrame:frame adType:1];
    ws.advertiseView.currentViewController = ws.currentViewController;
    ws.advertiseView .imgFilePath = filePath;
    ws.advertiseView .imgLinkUrl = [[NSUserDefaults standardUserDefaults] valueForKey:adUrl];
    ws.advertiseView .imgDeadline = [[NSUserDefaults standardUserDefaults] valueForKey:adDeadline];
    [SplashScreenDataManager getAdvertisingImageDataImageWithUrl:@"http://pic27.nipic.com/20130315/11511914_151013608193_2.jpg" imgLinkUrl:@"https://www.baidu.com" success:^(id data) {
        ws.advertiseView.adImageView.image = data;

    } fail:^(NSError *error) {
        
    }];
}


#pragma mark - GDTMobBannerViewDelegate
// 请求广告条数据成功后调用
//
// 详解:当接收服务器返回的广告数据成功后调用该函数
- (void)bannerViewDidReceived
{
    if([self.delegate respondsToSelector:@selector(bannerViewDidReceived)]){
        [self.delegate bannerViewDidReceived];
    }
}
/**
 This method is called when bannerAdView ad slot loaded successfully.
 @param bannerAdView : view for bannerAdView
 @param nativeAd : nativeAd for bannerAdView
 */
- (void)bannerAdViewDidLoad:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd{
    if([self.delegate respondsToSelector:@selector(bannerViewDidReceived)]){
        [self.delegate bannerViewDidReceived];
    }
}

// 请求广告条数据失败后调用
//
// 详解:当接收服务器返回的广告数据失败后调用该函数
- (void)bannerViewFailToReceived:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(bannerViewFailToReceived:)]){
        [self.delegate bannerViewFailToReceived:error];
    }
}
/**
 This method is called when bannerAdView ad slot failed to load.
 @param error : the reason of error
 */
- (void)bannerAdView:(BUBannerAdView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error{
    if([self.delegate respondsToSelector:@selector(bannerViewFailToReceived:)]){
        [self.delegate bannerViewFailToReceived:error];
    }
}

// 广告栏被点击后调用
//
// 详解:当接收到广告栏被点击事件后调用该函数
- (void)bannerViewClicked
{
    if([self.delegate respondsToSelector:@selector(bannerViewClicked)]){
        [self.delegate bannerViewClicked];
    }
}
/**
 This method is called when bannerAdView is clicked.
 */
- (void)bannerAdViewDidClick:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd{
    if([self.delegate respondsToSelector:@selector(bannerViewClicked)]){
        [self.delegate bannerViewClicked];
    }
}

/**
 *  banner条被用户关闭时调用
 *  详解:当打开showCloseBtn开关时，用户有可能点击关闭按钮从而把广告条关闭
 */
- (void)bannerViewWillClose{
    if([self.delegate respondsToSelector:@selector(bannerViewWillClose)]){
        [self.delegate bannerViewWillClose];
    }
}
/**
 This method is called when the user clicked dislike button and chose dislike reasons.
 @param filterwords : the array of reasons for dislike.
 */
- (void)bannerAdView:(BUBannerAdView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords{
    if([self.delegate respondsToSelector:@selector(bannerViewWillClose)]){
        [self.delegate bannerViewWillClose];
    }
}
/**
 *  全屏广告页已经被关闭
 */
- (void)bannerViewDidDismissFullScreenModal{
    if([self.delegate respondsToSelector:@selector(bannerViewDidDismissFullScreenModal)]){
        [self.delegate bannerViewDidDismissFullScreenModal];
    }
}
/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)bannerAdViewDidCloseOtherController:(BUBannerAdView *)bannerAdView interactionType:(BUInteractionType)interactionType{
    if([self.delegate respondsToSelector:@selector(bannerViewDidDismissFullScreenModal)]){
        [self.delegate bannerViewDidDismissFullScreenModal];
    }
}



#pragma mark - 这里是美数的回调函数
/**
 *  广告成功展示
 */
- (void)adSuccessPresentScreen:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(bannerViewDidReceived)]){
        [self.delegate bannerViewDidReceived];
    }
    NSLog(@"美数回调成功");
}

/**
 *  广告展示失败
 */
//- (void)adFailToPresent:(SplashScreenView *)splashAd withError:(NSError *)error{
//    if([self.delegate respondsToSelector:@selector(bannerViewFailToReceived:)]){
//        [self.delegate bannerViewFailToReceived:error];
//    }
//    [splashAd removeFromSuperview];
//}

/**
 *  广告点击回调
 */
- (void)adClicked:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(bannerViewClicked)]){
        [self.delegate bannerViewClicked];
    }
}

/**
 *  banner广告点击以后弹出全屏广告页完毕
 */
- (void)bannerViewDidPresentFullScreenModal{
    if([self.delegate respondsToSelector:@selector(bannerViewDidPresentFullScreenModal)]){
        [self.delegate bannerViewDidPresentFullScreenModal];
    }
}

/**
 *  广告将要关闭回调
 */
- (void)adWillClosed:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(bannerViewWillClose)]){
        [self.delegate bannerViewWillClose];
    }
    [splashAd removeFromSuperview];
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)adDidDismissFullScreenModal:(SplashScreenView *)splashAd{
    if([self.delegate respondsToSelector:@selector(bannerViewDidDismissFullScreenModal)]){
        [self.delegate bannerViewDidDismissFullScreenModal];
    }
}

@end
