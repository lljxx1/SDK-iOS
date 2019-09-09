//
//  MSNativeAdView.m
//  MSAdSDK
//
//  Created by yang on 2019/8/30.
//  Copyright © 2019 yang. All rights reserved.
//

#import "MSNativeAdView.h"
#import "SplashScreenView.h"
#import "SplashScreenDataManager.h"
#import "ADDetailViewController.h"
#import <StoreKit/StoreKit.h>
#import "MSSDKModel.h"
#import "GDTUnifiedNativeAd.h"
#import <BUAdSDK/BUNativeAd.h>

@interface MSNativeAdView()<BUNativeAdDelegate,GDTUnifiedNativeAdDelegate,SKStoreProductViewControllerDelegate>
@property (nonatomic, strong) UILabel *titleLabel;//标题
@property (nonatomic, strong) UILabel *contentLabel;//描述
@property (nonatomic, strong) UIImageView *imageView;//大图
@property (nonatomic, strong) UIButton *actionButton;//按钮
@property (nonatomic, strong)UIViewController *currentViewController;
@property (strong, nonatomic)NSMutableArray *dataArray;

@property (nonatomic, strong) GDTUnifiedNativeAd *unifiedNativeAd;

@property (nonatomic, strong) BUNativeAd *ad;

@end

@implementation MSNativeAdView
- (instancetype)initWithFrame:(CGRect)frame curController:(UIViewController*)controller{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [UILabel new];
        self.contentLabel = [UILabel new];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textColor = MSUIColorFromRGB(0x666666);
        
        self.imageView = [UIImageView new];
        self.imageView.backgroundColor = MSUIColorFromRGB(0xF5F5F5);
        self.imageView.contentMode =  UIViewContentModeScaleAspectFit;
        self.actionButton = [UIButton new];
        [self.actionButton setTitle:@"下载" forState:UIControlStateNormal];
        _actionButton.userInteractionEnabled = YES;
        _actionButton.backgroundColor = [UIColor orangeColor];
        _actionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.imageView];
        [self addSubview:self.actionButton];
        self.nativeAdViewShowType = MSLeftImage;
        [self loadData];
        
        [self.actionButton addTarget:self action:@selector(pushToAdVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
#pragma mark - 进入详情
- (void)pushToAdVC{
    MSWS(ws);

    //点击广告图时，广告图消失，同时像首页发送通知，并把广告页对应的地址传给首页
    NSInteger openType = ws.adModel.target_type;
    if (openType == 0) {
        ADDetailViewController *vc = [[ADDetailViewController alloc]init];
        if (ws.adModel.dUrl.count>0) {
            vc.URLString = ws.adModel.dUrl[0];
        }
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:vc animated:YES completion:^(){
          
        }];
        vc.closeBlock = ^{
        
        };
    }
    //    else if (openType == 1) {
    //        //第一种方法  直接跳转
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1168889295"]];
    //    }
    else if (openType == 1) {
        //第二中方法  应用内跳转
        //1:导入StoreKit.framework,控制器里面添加框架#import <StoreKit/StoreKit.h>
        //2:实现代理SKStoreProductViewControllerDelegate
        SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        storeProductViewContorller.delegate = self;
        //        ViewController *viewc = [[ViewController alloc]init];
        //        __weak typeof(viewc) weakViewController = viewc;
        
        //加载一个新的视图展示
        [storeProductViewContorller loadProductWithParameters:
         //appId
         @{SKStoreProductParameterITunesItemIdentifier : @"1168889295"} completionBlock:^(BOOL result, NSError *error) {
             //回调
             if(error){
                 NSLog(@"错误%@",error);
             }else{
                 //AS应用界面
                 [self.currentViewController presentViewController:storeProductViewContorller animated:YES completion:^(){
//                     if([ws.delegate respondsToSelector:@selector(bannerViewDidPresentFullScreenModal)]){
//                         [ws.delegate bannerViewDidPresentFullScreenModal];
//                     }
                 }];
             }
         }];
    }
}

#pragma mark - 评分取消按钮监听
//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self.currentViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)loadData{
    MSWS(ws);
    NSMutableDictionary *dict = [MSCommCore publicParams];
    NSString *BundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [dict setObject:BundleId forKey:@"app_package"];
    [dict setObject:[MSAdSDK appId] forKey:@"app_id"];
    [dict setObject:@"1004465" forKey:@"pid"];
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
                ws.adModel = model;
            });
        }
        else if ([response[@"Response_type"] isEqualToString:@"SDK"]) {
            if (ws.dataArray.count>0) {
                MSSDKModel *sdkModel = ws.dataArray[0];
                if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"GDT"]) {
                    
                    ws.unifiedNativeAd = [[GDTUnifiedNativeAd alloc] initWithAppId:sdkModel.app_id placementId:sdkModel.pid];
                    ws.unifiedNativeAd.delegate = ws;
                    [ws.unifiedNativeAd loadAdWithAdCount:1];
                   
                }
                else if (sdkModel.sdk&&[sdkModel.sdk isEqualToString:@"CSJ"]){
                    [ws loadBUNativeAd:sdkModel.pid];
                }
            }
        }
        
    } faile:^(NSError *error) {
        if([ws.delegate respondsToSelector:@selector(nativeAd: didFailWithError:)]){
            [ws.delegate nativeAd:ws didFailWithError:error];
        }
    }];
    
}

#pragma mark - 穿山甲加载数据
- (void)loadBUNativeAd:(NSString*)slotID {
    MSWS(ws);
    BUNativeAd *nad = [[BUNativeAd alloc] init];;
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    BUSize *imgSize1 = [[BUSize alloc] init];
    imgSize1.width = 1080;
    imgSize1.height = 1920;
    slot1.ID = slotID;
    slot1.AdType = BUAdSlotAdTypeFeed;
    slot1.position = BUAdSlotPositionFeed;
    slot1.imgSize = imgSize1;
    slot1.isSupportDeepLink = YES;
    nad.adslot = slot1;
    nad.rootViewController = self.currentViewController;
    nad.delegate = ws;
    ws.ad = nad;
    [nad loadAdData];
}

#pragma mark - BUNativeAdDelegate

- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    self.ad = nil;
    self.ad = nativeAd;
}

#pragma mark - GDTUnifiedNativeAdDelegate
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error
{
    if (!error && unifiedNativeAdDataObjects.count > 0) {
        NSLog(@"成功请求到广告数据");
        GDTUnifiedNativeAdDataObject *object = unifiedNativeAdDataObjects[0];
        MSAdModel *model = [[MSAdModel alloc]init];
        
        return;
    }
    
    if (error.code == 5004) {
        NSLog(@"没匹配的广告，禁止重试，否则影响流量变现效果");
    } else if (error.code == 5005) {
        NSLog(@"流量控制导致没有广告，超过日限额，请明天再尝试");
    } else if (error.code == 5009) {
        NSLog(@"流量控制导致没有广告，超过小时限额");
    } else if (error.code == 5006) {
        NSLog(@"包名错误");
    } else if (error.code == 5010) {
        NSLog(@"广告样式校验失败");
    } else if (error.code == 3001) {
        NSLog(@"网络错误");
    } else if (error.code == 5013) {
        NSLog(@"请求太频繁，请稍后再试");
    } else if (error) {
        NSLog(@"ERROR: %@", error);
    }
}


- (void)setAdModel:(MSAdModel *)adModel{
    self.titleLabel.text = adModel.title;
    self.contentLabel.text = adModel.content;
    if (adModel.srcUrls.count>0) {
        NSURL *iconURL = [NSURL URLWithString:adModel.srcUrls[0]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *iconData = [NSData dataWithContentsOfURL:iconURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:iconData];
                self.imageView.image = image;
            });
        });
    }
    
    if (adModel.target_type ==0) {
        [self.actionButton setTitle:@"浏览" forState:UIControlStateNormal];
    }
    else{
        [self.actionButton setTitle:@"下载" forState:UIControlStateNormal];
    }
    
}

- (void)setNativeAdViewShowType:(MSNativeAdViewShowType)nativeAdViewShowType{
    _nativeAdViewShowType =nativeAdViewShowType;
    
//    MSLeftImage= 0, // 展示左图右文+下载按钮
//    MSLeftImageNoButton = 1, // 展示左图右文
//    MSBottomImage = 2, // 展示上文下大图
    self.actionButton.hidden = YES;
    if (nativeAdViewShowType == MSLeftImage) {
        self.actionButton.hidden = NO;
        self.imageView.frame = CGRectMake(5, 5, self.frame.size.width/2-10, self.frame.size.height-10);
        self.titleLabel.frame = CGRectMake(self.frame.size.width/2, 5, self.frame.size.width/2-10, 20);
        self.contentLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width/2-10, self.frame.size.height-10-CGRectGetMaxY(self.titleLabel.frame)-20);
        self.actionButton.frame = CGRectMake(self.frame.size.width-60, self.frame.size.height-20, 60, 20);
        
    }
    else if (nativeAdViewShowType == MSLeftImageNoButton){
        self.imageView.frame = CGRectMake(5, 5, self.frame.size.width/2-10, self.frame.size.height-10);
        self.titleLabel.frame = CGRectMake(self.frame.size.width/2, 5, self.frame.size.width/2-10, 20);
        self.contentLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width/2-10, self.frame.size.height-10-CGRectGetMaxY(self.titleLabel.frame));
    }
    else if (nativeAdViewShowType == MSBottomImage){
        self.titleLabel.frame = CGRectMake(5, 5, self.frame.size.width-10, 20);
        self.contentLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width-10, 30);
        self.imageView.frame = CGRectMake(5, CGRectGetMaxY(self.contentLabel.frame), self.frame.size.width-10, 50);
    }
    
    
}

@end
