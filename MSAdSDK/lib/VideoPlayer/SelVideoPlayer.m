    //
//  SelVideoPlayer.m
//  SelVideoPlayer
//
//  Created by zhuku on 2018/1/26.
//  Copyright © 2018年 selwyn. All rights reserved.
//

#import "SelVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "SelPlayerConfiguration.h"
#import "SplashScreenDataManager.h"
#import "ADDetailViewController.h"
#import <StoreKit/StoreKit.h>

/** 播放器的播放状态 */
typedef NS_ENUM(NSInteger, SelVideoPlayerState) {
    SelVideoPlayerStateFailed,     // 播放失败
    SelVideoPlayerStateBuffering,  // 缓冲中
    SelVideoPlayerStatePlaying,    // 播放中
    SelVideoPlayerStatePause,      // 暂停播放
};

@interface SelVideoPlayer()<SelPlaybackControlsDelegate,SKStoreProductViewControllerDelegate>

/** 播放器 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** 播放器item */
@property (nonatomic, strong) AVPlayer *player;
/** 播放器layer */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/** 是否播放完毕 */
@property (nonatomic, assign) BOOL isFinish;
/** 是否处于全屏状态 */
@property (nonatomic, assign) BOOL isFullScreen;
/** 视频播放控制面板 */
@property (nonatomic, strong) SelPlaybackControls *playbackControls;
/** 非全屏状态下播放器 superview */
@property (nonatomic, strong) UIView *originalSuperview;
/** 非全屏状态下播放器 frame */
@property (nonatomic, assign) CGRect originalRect;
/** 时间监听器 */
@property (nonatomic, strong) id timeObserve;
/** 播放器的播放状态 */
@property (nonatomic, assign) SelVideoPlayerState playerState;
/** 是否结束播放 */
@property (nonatomic, assign) BOOL playDidEnd;
/** 播放完的视图 */
@property (nonatomic, strong) UIView *playDidEndView;

@end

@implementation SelVideoPlayer

///**
// 初始化播放器
// @param configuration 播放器配置信息
// */
//- (instancetype)initWithFrame:(CGRect)frame configuration:(SelPlayerConfiguration *)configuration
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//    }
//    return self;
//}

- (UIView*)playDidEndView{
    if (!_playDidEndView) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        _playDidEndView = [[UIView alloc]initWithFrame:keyWindow.bounds];
    }
    return _playDidEndView;
}

- (void)setAdModel:(MSAdModel *)adModel{
    MSWS(ws);
    ws.playDidEndView.hidden = YES;
    _adModel = adModel;
    if (adModel&&adModel.video_endcover) {
        NSString *video_endcover = adModel.video_endcover;
        [SplashScreenDataManager getAdvertisingImageDataImageWithUrl:video_endcover imgLinkUrl:video_endcover success:^(id data) {
            // 1.广告图片
                UIImageView *adImageView = [[UIImageView alloc] initWithFrame:ws.playDidEndView.frame];
             adImageView.userInteractionEnabled = YES;
             adImageView.clipsToBounds = YES;
             UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToAdVC)];
             [adImageView addGestureRecognizer:tap];
            [ws.playDidEndView addSubview:adImageView];
            
        } fail:^(NSError *error) {
               
        }];
    }
}

- (void)pushToAdVC{
    MSWS(ws);
    ws.playDidEndView.hidden= YES;
    NSInteger openType = ws.adModel.target_type;
    if (ws.adModel&&ws.adModel.dUrl.count>0) {
        NSString *dUrl = ws.adModel.dUrl[0];
        if (openType == 0) {
            ADDetailViewController *vc = [[ADDetailViewController alloc]init];
            vc.URLString = dUrl;

            [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:vc animated:YES completion:^(){
            }];
            vc.closeBlock = ^{

            };
        }
        else if (openType == 1) {
            //第二中方法  应用内跳转
            //1:导入StoreKit.framework,控制器里面添加框架#import <StoreKit/StoreKit.h>
            //2:实现代理SKStoreProductViewControllerDelegate
            SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
            storeProductViewContorller.delegate = ws;
            //加载一个新的视图展示
            [storeProductViewContorller loadProductWithParameters:
             //appId
             @{SKStoreProductParameterITunesItemIdentifier : @"1168889295"} completionBlock:^(BOOL result, NSError *error) {
                 //回调
                 if(error){
                     NSLog(@"错误%@",error);
                 }else{
                     //AS应用界面
                     [ws.currentViewController presentViewController:storeProductViewContorller animated:YES completion:^(){
                     
                     }];
                 }
             }];
        }
    }
    
}

#pragma mark - 评分取消按钮监听
//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self.currentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPlayerConfiguration:(SelPlayerConfiguration *)playerConfiguration{
    _playerConfiguration = playerConfiguration;
    [self _setupPlayer];
    [self _setupPlayControls];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterPlayground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}


/** 屏幕翻转监听事件 */
- (void)orientationChanged:(NSNotification *)notify
{
    if (_playerConfiguration.shouldAutorotate) {
        [self orientationAspect];
    }
}

/** 根据屏幕旋转方向改变当前视频屏幕状态 */
- (void)orientationAspect
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft){
        if (!_isFullScreen){
           [self _videoZoomInWithDirection:UIInterfaceOrientationLandscapeRight];
        }
    }
    else if (orientation == UIDeviceOrientationLandscapeRight){
        if (!_isFullScreen){
           [self _videoZoomInWithDirection:UIInterfaceOrientationLandscapeLeft];
        }
    }
    else if(orientation == UIDeviceOrientationPortrait){
        if (_isFullScreen){
            [self _videoZoomOut];
        }
    }
}

/**
 视频放大全屏幕
 @param orientation 旋转方向
 */
- (void)_videoZoomInWithDirection:(UIInterfaceOrientation)orientation
{
    _originalSuperview = self.superview;
    _originalRect = self.frame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    
    [UIView animateWithDuration:duration animations:^{
        if (orientation == UIInterfaceOrientationLandscapeLeft){
            self.transform = CGAffineTransformMakeRotation(-M_PI/2);
        }else if (orientation == UIInterfaceOrientationLandscapeRight) {
            self.transform = CGAffineTransformMakeRotation(M_PI/2);
        }
    }completion:^(BOOL finished) {
        
    }];
    
    self.frame = keyWindow.bounds;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.isFullScreen = YES;
    //显示或隐藏状态栏
    [self.playbackControls _showOrHideStatusBar];
}

/** 视频退出全屏幕 */
- (void)_videoZoomOut
{
    //退出全屏时强制取消隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
    }completion:^(BOOL finished) {
        
    }];
    self.frame = _originalRect;
    [_originalSuperview addSubview:self];
    [_originalSuperview addSubview:self.playDidEndView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.isFullScreen = NO;
}

/** 播放视频 */
- (void)_playVideo
{
    if (self.playDidEnd && self.playbackControls.videoSlider.value == 1.0) {
        //若播放已结束重新播放
        [self _replayVideo];
    }else
    {
        [_player play];
        [self.playbackControls _setPlayButtonSelect:YES];
        if (self.playerState == SelVideoPlayerStatePause) {
            self.playerState = SelVideoPlayerStatePlaying;
        }
        
//        音/视频广告(播放开始时上报)
        if (self.adModel.video_start.count>0) {
            NSString *video_start = self.adModel.video_start[0];
            [[MSSDKNetSession wsqflyNetWorkingShare]get:video_start param:nil maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
                           
                       } requestHead:^(id response) {
                           
                       } faile:^(NSError *error) {
                           
                       }];
        }
    }
}

/** 暂停播放 */
- (void)_pauseVideo
{
    [_player pause];
    [self.playbackControls _setPlayButtonSelect:NO];
    if (self.playerState == SelVideoPlayerStatePlaying) {
        self.playerState = SelVideoPlayerStatePause;
    }
}

/** 重新播放 */
- (void)_replayVideo
{
    self.playDidEnd = NO;
    [_player seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self _playVideo];
}

/** 监听播放器事件 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [_playbackControls _setPlayerProgress:timeInterval / totalDuration];
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
        // 当无缓冲视频数据时
        if (self.playerItem.playbackBufferEmpty) {
            self.playerState = SelVideoPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        // 当视频缓冲好时
        if (self.playerItem.playbackLikelyToKeepUp && self.playerState == SelVideoPlayerStateBuffering){
            self.playerState = SelVideoPlayerStatePlaying;
        }
    }
    else if ([keyPath isEqualToString:@"status"])
    {
        if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self.layer insertSublayer:_playerLayer atIndex:0];
            self.playerState = SelVideoPlayerStatePlaying;
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            self.playerState = SelVideoPlayerStateFailed;
        }
    }
}

/**
 *  计算缓冲进度
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.playerState = SelVideoPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self _pauseVideo];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self _playVideo];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp)
        {
            [self bufferingSomeSecond];
        }
        
    });
}

/** 应用进入后台 */
- (void)appDidEnterBackground:(NSNotification *)notify
{
    [self _pauseVideo];
}

/** 应用进入前台 */
- (void)appDidEnterPlayground:(NSNotification *)notify
{

}

/** 视频播放结束事件监听 */
- (void)videoDidPlayToEnd:(NSNotification *)notify
{
    self.playDidEndView.hidden= NO;
    self.playDidEnd = YES;
    if (_playerConfiguration.repeatPlay) {
        [self _replayVideo];
    }else
    {
        [self _pauseVideo];
    }
    if (self.adModel.video_complete.count>0) {
            NSString *video_complete = self.adModel.video_complete[0];
        [[MSSDKNetSession wsqflyNetWorkingShare]get:video_complete param:nil maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
                   
               } requestHead:^(id response) {
                   
               } faile:^(NSError *error) {
                   
          }];
    }
  
}

/** 创建播放器 以及控制面板*/
- (void)_setupPlayer
{
    self.playerItem = [AVPlayerItem playerItemWithURL:_playerConfiguration.sourceUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self _setVideoGravity:_playerConfiguration.videoGravity];
    self.backgroundColor = [UIColor blackColor];
    
    /** 创建进度监听器 */
    [self createTimer];
    
    if (_playerConfiguration.shouldAutoPlay) {
        [self _playVideo];
    }
}


/** 添加播放器控制面板 */
- (void)_setupPlayControls
{
    [self addSubview:self.playbackControls];
}


/** 创建进度监听器 */
- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    if(weakSelf.isCountDown){
        __block NSInteger timeout = 8;
        // 获取全局子线程队列
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        // 创建timer添加到队列中
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        // 设置时间间隔
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0);
        // 处理事件block
        dispatch_source_set_event_handler(timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                timeout--;
                [weakSelf.playbackControls.countButton setTitle:timeout > 0 ? [NSString stringWithFormat:@"跳过%ld", (long)timeout] : @"关闭" forState:UIControlStateNormal];
                // 倒计时结束，关闭定时器
                if (timeout <= 0) {
                    dispatch_source_cancel(timer);
                }
            });
        });
        // 定时器
        dispatch_resume(timer);
      
    }
    
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf.playbackControls _setPlaybackControlsWithPlayTime:currentTime totalTime:totalTime sliderValue:value];
            NSInteger countTime = (NSInteger)(totalTime-currentTime);
            if(weakSelf.isCountDown){
                if (countTime==0) {
                    [weakSelf.playbackControls _retryButtonShow:YES];
                }
            }
            else{
                if (countTime==0) {
                    [weakSelf.playbackControls.countButton setTitle:@"关闭" forState:UIControlStateNormal];
                    [weakSelf.playbackControls _retryButtonShow:YES];
                }
                else{
                  
                    [weakSelf.playbackControls.countButton setTitle:[NSString stringWithFormat:@"%ld",countTime] forState:UIControlStateNormal];
                                      //根据播放进度去上报
                    CGFloat avarateTime =countTime;
                    [weakSelf videoUpload:avarateTime];
                }
            }
        }
    }];
}

/**
上报百分比
@param avarateTime 上报百分比
*/

- (void)videoUpload:(NSInteger)avarateTime{
    MSWS(ws);
    float stringFloat = (float)avarateTime/ws.adModel.video_duration;
    NSLog(@"%.2f",stringFloat);//ok

//    CGFloat stringFloat =(ws.adModel.video_duration-avarateTime)*1.00/(ws.adModel.video_duration*1.00);
                            
    if (stringFloat == 0.25||stringFloat == 0.50||stringFloat==0.75 ) {
        NSString *videoStr = @"";
        if (stringFloat == 0.25) {
            if (ws.adModel.video_one_quarter.count>0) {
                videoStr = ws.adModel.video_one_quarter[0];
            }
        }
        else if (stringFloat == 0.50){
            if (ws.adModel.video_one_half.count>0) {
                   videoStr = ws.adModel.video_one_half[0];
               }
        }
        else if (stringFloat == 0.75){
            if (ws.adModel.video_three_quarter.count>0) {
                videoStr = ws.adModel.video_three_quarter[0];
            }
        }

    [[MSSDKNetSession wsqflyNetWorkingShare]get:videoStr param:nil maskState:WsqflyNetSessionMaskStateNone backData:WsqflyNetSessionResponseTypeJSON success:^(id response) {
             
         } requestHead:^(id response) {
             
         } faile:^(NSError *error) {
             
    }];
        
    }
}

/**
 配置playerLayer拉伸方式
 @param videoGravity 拉伸方式
 */
- (void)_setVideoGravity:(SelVideoGravity)videoGravity
{
    NSString *fillMode = AVLayerVideoGravityResize;
    switch (videoGravity) {
        case SelVideoGravityResize:
            fillMode = AVLayerVideoGravityResize;
            break;
        case SelVideoGravityResizeAspect:
            fillMode = AVLayerVideoGravityResizeAspect;
            break;
        case SelVideoGravityResizeAspectFill:
            fillMode = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
    _playerLayer.videoGravity = fillMode;
}


/**
 @param playerState 播放器的播放状态
 */
- (void)setPlayerState:(SelVideoPlayerState)playerState
{
    _playerState = playerState;
    switch (_playerState) {
        case SelVideoPlayerStateBuffering:
        {
            [_playbackControls _activityIndicatorViewShow:YES];
        }
            break;
        case SelVideoPlayerStatePlaying:
        {
            [_playbackControls _activityIndicatorViewShow:NO];
        }
            break;
        case SelVideoPlayerStateFailed:
        {
            [_playbackControls _activityIndicatorViewShow:NO];
            [_playbackControls _retryButtonShow:YES];
        }
            break;
        default:
            break;
    }
}

/** 改变全屏切换按钮状态 */
- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    _playbackControls.isFullScreen = isFullScreen;
}


/** 根据playerItem，来添加移除观察者 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

/** 播放器控制面板 */
- (SelPlaybackControls *)playbackControls
{
    if (!_playbackControls) {
        _playbackControls = [[SelPlaybackControls alloc]init];
        _playbackControls.delegate = self;
        _playbackControls.hideInterval = _playerConfiguration.hideControlsInterval;
        _playbackControls.statusBarHideState = _playerConfiguration.statusBarHideState;
    }
    return _playbackControls;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    self.playbackControls.frame = self.bounds;
}

/** 释放播放器 */
- (void)_deallocPlayer
{
    [self _pauseVideo];
    
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

/** 释放Self */
- (void)dealloc
{
//    self.playbackControls.delegate = nil;
//    self.playerItem = nil;
    [self.playbackControls _playerCancelAutoHidePlaybackControls];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    self.playerLayer = nil;
    self.player = nil;
}

#pragma mark 播放器控制面板代理
/**
 播放按钮点击事件
 @param selected 播放按钮选中状态
 */
- (void)playButtonAction:(BOOL)selected
{
    if (selected){
        [self _pauseVideo];
    }else{
        [self _playVideo];
    }
}

/** 全屏切换按钮点击事件 */
- (void)fullScreenButtonAction
{
    if (!_isFullScreen) {
        [self _videoZoomInWithDirection:UIInterfaceOrientationLandscapeRight];
    }else
    {
        [self _videoZoomOut];
    }
}

/** 控制面板单击事件 */
- (void)tapGesture
{
    
    if (self.playerState == SelVideoPlayerStatePlaying) {
        [self _pauseVideo];
    }
    else if (self.playerState == SelVideoPlayerStatePause)
    {
        [self _playVideo];
    }
    
//    if (_delegate && [_delegate respondsToSelector:@selector(tapGesture)]) {
//        [_delegate tapGesture];
//    }
//    [_playbackControls _playerShowOrHidePlaybackControls];
}

/** 控制面板双击事件 */
- (void)doubleTapGesture
{
    if (_playerConfiguration.supportedDoubleTap) {
        if (self.playerState == SelVideoPlayerStatePlaying) {
            [self _pauseVideo];
        }
        else if (self.playerState == SelVideoPlayerStatePause)
        {
            [self _playVideo];
        }
    }
}

/** 重新加载视频 */
- (void)retryButtonAction
{
    self.playDidEndView.hidden= YES;
    [_playbackControls _retryButtonShow:NO];
    [_playbackControls _activityIndicatorViewShow:YES];
//    [self _setupPlayer];
    /** 创建进度监听器 */
    [self createTimer];
    [self _playVideo];
}

//倒计时关闭
- (void)countButtonAction{
    if (_delegate && [_delegate respondsToSelector:@selector(countButtonAction)]) {
        [_delegate countButtonAction];
    }
}

#pragma mark 滑杆拖动代理
/** 开始拖动 */
-(void)videoSliderTouchBegan:(SelVideoSlider *)slider{
    [self _pauseVideo];
    [_playbackControls _playerCancelAutoHidePlaybackControls];
}
/** 结束拖动 */
-(void)videoSliderTouchEnded:(SelVideoSlider *)slider{

    if (slider.value != 1) {
        self.playDidEnd = NO;
    }
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    }else{
        //继续播放
        [self _playVideo];
    }
    [_playbackControls _playerAutoHidePlaybackControls];
}

/** 拖拽中 */
-(void)videoSliderValueChanged:(SelVideoSlider *)slider{
    CGFloat totalTime = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    CGFloat dragedSeconds = totalTime * slider.value;
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(dragedCMTime);
    [_playbackControls _setPlaybackControlsWithPlayTime:currentTime totalTime:totalTime sliderValue:slider.value];
}

@end
