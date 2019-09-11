//
//  SplashScreenView.m
//  启动屏加启动广告页
//
//  Created by WOSHIPM on 16/8/9.
//  Copyright © 2016年 WOSHIPM. All rights reserved.
//

#import "SplashScreenView.h"
#import "ADDetailViewController.h"
#import <StoreKit/StoreKit.h>
#import "SplashScreenView.h"
#import "SplashScreenDataManager.h"
#import "SelVideoPlayer.h"
#import "SelPlayerConfiguration.h"
@interface  SplashScreenView()<SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIButton *countButton;
//视频播放
@property (nonatomic, strong) SelVideoPlayer*player;

@property (nonatomic, strong) SelPlayerConfiguration *configuration;


@property (nonatomic, strong) UILabel *adLabel;

@property (nonatomic, strong) NSTimer *countTimer;

@property (nonatomic, assign) NSInteger count;

@end
 

@implementation SplashScreenView

- (NSTimer *)countTimer
{
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

- (instancetype)initWithFrame:(CGRect)frame adType:(NSInteger)adType
{
    if (self = [super initWithFrame:frame]) {
        self.adType = adType;
        [self setCustomView:adType];
    }
    return self;
}

//- (UIViewController*)currentViewController{
//    if (!_currentViewController) {
//        _currentViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
//
//    }
//    return _currentViewController;
//}
- (void)setCustomView:(NSInteger)adType{
    _bgView = [UIView new];
    _bgView.frame = [UIScreen mainScreen].bounds;
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.5;
    
    // 1.广告图片
    _adImageView = [[UIImageView alloc] initWithFrame:self.frame];
    _adImageView.userInteractionEnabled = YES;

    _adImageView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToAdVC)];
    [_adImageView addGestureRecognizer:tap];
    
    // 2.跳过按钮
    _countButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _countButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 84, 60, 60, 30);
    [_countButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//    _countButton.backgroundColor = [UIColor redColor];

    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = MSUIColorFromRGB(0x55555);
    label.alpha = 1.0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"广告";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:10];
    label.frame  = CGRectMake(self.frame.size.width-40, self.frame.size.height-20, 40, 20) ;
    self.adLabel = label;
    
    SelPlayerConfiguration *configuration = [[SelPlayerConfiguration alloc]init];
    configuration.shouldAutoPlay = YES;     //自动播放
    configuration.supportedDoubleTap = NO;     //支持双击播放暂停
    configuration.shouldAutorotate = YES;   //自动旋转
    configuration.repeatPlay = NO;     //重复播放
    configuration.statusBarHideState = SelStatusBarHideStateNever;     //设置状态栏隐藏
    //设置播放数据源
    configuration.videoGravity = SelVideoGravityResizeAspect;   //拉伸方式
    self.configuration = configuration;
    
    _player = [[SelVideoPlayer alloc]initWithFrame:self.frame];
    
    self.player.backgroundColor = [UIColor redColor];
    //0是开屏 1是banner  2s插屏
    if (adType==0) {
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        _countButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_countButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _countButton.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.6];
        _countButton.layer.cornerRadius = 4;
        
        [self addSubview:_adImageView];
        [self addSubview:self.player];
        [self addSubview:_countButton];
        [self addSubview:label];
    }
    else if (adType==1){
        _countButton.imageView.contentMode=UIViewContentModeCenter;
        _adImageView.contentMode = UIViewContentModeScaleToFill;
        _countButton.frame = CGRectMake(self.frame.size.width - 20, 2, 15, 15);
        [_countButton setBackgroundImage:[UIImage imageNamed:@"BUAdSDK.bundle/bu_fullClose"] forState:UIControlStateNormal];
        [self addSubview:_adImageView];
        [self addSubview:self.player];
        [self addSubview:_countButton];
        [self addSubview:label];
    }
    else if (adType==2){
        [_countButton setBackgroundImage:[UIImage imageNamed:@"BUAdSDK.bundle/bu_fullClose"] forState:UIControlStateNormal];
        _countButton.imageView.contentMode=UIViewContentModeCenter;
        _adImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_adImageView];
        [self addSubview:self.player];
        [self addSubview:label];
    }
}

-(void)setImgFilePath:(NSString *)imgFilePath{
    _imgFilePath = imgFilePath;
     _adImageView.image = [UIImage imageWithContentsOfFile:_imgFilePath];
}
-(void)setImgDeadline:(NSString *)imgDeadline{
    _imgDeadline = imgDeadline;
}

- (void)pushToAdVC{
    MSWS(ws);
    
    if([ws.delegate respondsToSelector:@selector(adClicked:)]){
        [ws.delegate adClicked:ws];
    }
    
    //点击广告图时，广告图消失，同时像首页发送通知，并把广告页对应的地址传给首页
    [ws dismiss];
    NSInteger openType = ws.adModel.target_type;
    if (openType == 0) {
        ADDetailViewController *vc = [[ADDetailViewController alloc]init];
        vc.URLString = self.imgLinkUrl;
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:vc animated:YES completion:^(){
            if([ws.delegate respondsToSelector:@selector(bannerViewDidPresentFullScreenModal)]){
                [ws.delegate bannerViewDidPresentFullScreenModal];
            }
        }];
        vc.closeBlock = ^{
            if([ws.delegate respondsToSelector:@selector(adDidDismissFullScreenModal:)]){
                [ws.delegate adDidDismissFullScreenModal:ws];
            }
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
                     if([ws.delegate respondsToSelector:@selector(bannerViewDidPresentFullScreenModal)]){
                         [ws.delegate bannerViewDidPresentFullScreenModal];
                     }
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

- (void)countDown
{
    MSWS(ws);
    ws.count --;
    [ws.countButton setTitle:[NSString stringWithFormat:@"跳过 %ld",(long)ws.count] forState:UIControlStateNormal];
    if (ws.count == 0) {
        
        [ws dismiss];
    }
}

- (void)showSplashScreenWithTime:(NSInteger)ADShowTime adType:(NSInteger)adType
{
    MSWS(ws);
    NSString *imageUrl = @"";
    NSString *dUrl = @"";

    if ([ws.adModel.srcUrls count]>0) {
        imageUrl = ws.adModel.srcUrls[0];
    }
    if ([ws.adModel.dUrl count]>0) {
        dUrl = ws.adModel.dUrl[0];
    }
    
    //图片
    if (ws.adModel.creative_type == 1) {
        ws.player.hidden = YES;
        [SplashScreenDataManager getAdvertisingImageDataImageWithUrl:imageUrl imgLinkUrl:dUrl success:^(id data) {
            ws.adImageView.image = data;
            if (adType==0) {//开屏
                ws.ADShowTime = ADShowTime;
                [ws.countButton setTitle:[NSString stringWithFormat:@"跳过%ld",ADShowTime] forState:UIControlStateNormal];
                
                [ws startTimer];
                UIWindow *window = [[UIApplication sharedApplication].delegate window];
                window.hidden = NO;
                [window addSubview:ws];
                
            }
            else  if (adType==1) {//banner
                
            }
            else  if (adType==2) {//插图
                self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-ws.adImageView.image.size.width/2)/2, ([UIScreen mainScreen].bounds.size.height-ws.adImageView.image.size.height/2)/2, ws.adImageView.image.size.width/2, ws.adImageView.image.size.height/2);
                
                ws.adImageView.frame = CGRectMake(0, 0, ws.adImageView.image.size.width/2, ws.adImageView.image.size.height/2);
                
                ws.countButton.frame = CGRectMake(CGRectGetMaxX(self.frame)-20, ([UIScreen mainScreen].bounds.size.height-ws.adImageView.image.size.height/2)/2-20, 15, 15);
                ws.adLabel.frame  = CGRectMake(self.frame.size.width-40, self.frame.size.height-20, 40, 20) ;
                
                
                
                [ws showAd];
            }
            
//            if([ws.delegate respondsToSelector:@selector(adSuccessPresentScreen:)]){
//                [ws.delegate adSuccessPresentScreen:ws];
//            }
            
        } fail:^(NSError *error) {
            if([ws.delegate respondsToSelector:@selector(adFailToPresent:withError:)]){
                [ws.delegate adFailToPresent:ws withError:error];
            }
        }];
    }
    //播放的是视频
    else if (ws.adModel.creative_type == 2){
        ws.adImageView.hidden = YES;
        
        self.configuration.sourceUrl = [NSURL URLWithString:@"http://sc.ghssad.com/sources/s/2019030416/174/5c7ce11ac4103.mp4"];
        ws.player.playerConfiguration = self.configuration;
        
        if (adType==0) {//开屏
            ws.ADShowTime = ADShowTime;
            [ws.countButton setTitle:[NSString stringWithFormat:@"跳过%ld",ADShowTime] forState:UIControlStateNormal];
            [ws startTimer];
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            window.hidden = NO;
            [window addSubview:ws];
            
        }
        else  if (adType==1) {//banner
            
        }
        else  if (adType==2) {//插图
            self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-ws.adModel.width)/2, ([UIScreen mainScreen].bounds.size.height-ws.adModel.height)/2, ws.adModel.width/2, ws.adModel.height/2);
            ws.player.frame = self.frame;
            ws.countButton.frame = CGRectMake(CGRectGetMaxX(self.frame)-20, ([UIScreen mainScreen].bounds.size.height-ws.adImageView.image.size.height/2)/2-20, 15, 15);
            ws.adLabel.frame  = CGRectMake(self.frame.size.width-40, self.frame.size.height-20, 40, 20) ;
            [ws showAd];
        }
    }
}

/**
 *  显示插屏广告
 *  详解：显示广告
 */
- (void)showAd{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    window.hidden = NO;
    [window addSubview:self.bgView];
    [window addSubview:self];
    [window addSubview:self.countButton];

}


// 定时器倒计时
- (void)startTimer
{
    MSWS(ws);
    //为了保证UI刷新在主线程中完成。
    [ws performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)startTimeroOnMainThread{
    MSWS(ws);
    ws.count = ws.ADShowTime;
    [[NSRunLoop currentRunLoop] addTimer:ws.countTimer forMode:NSRunLoopCommonModes];
}



// 移除广告页面
- (void)dismiss
{
    MSWS(ws);
    [ws.countTimer invalidate];
    ws.countTimer = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        ws.alpha = 0.f;
        ws.bgView.alpha = 0.f;
        ws.countButton.alpha = 0.f;

        if([ws.delegate respondsToSelector:@selector(adWillClosed:)]){
            [ws.delegate adWillClosed:ws];
        }
        
    } completion:^(BOOL finished) {
        if([ws.delegate respondsToSelector:@selector(adClosed:)]){
            [ws.delegate adClosed:ws];
        }
        [self removeFromSuperview];
        [self.bgView removeFromSuperview];
        [self.countButton removeFromSuperview];
    }];
    
}


@end
