//
//  SelVideoPlayer.h
//  SelVideoPlayer
//
//  Created by zhuku on 2018/1/26.
//  Copyright © 2018年 selwyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelPlaybackControls.h"

/** 播放器控制面板代理 */
@protocol SelVideoPlayerDelegate <NSObject>

@required
//倒计时关闭
- (void)countButtonAction;

@end

@class SelPlayerConfiguration;
@interface SelVideoPlayer : UIView

///**
// 初始化播放器
// @param configuration 播放器配置信息
// */
//- (instancetype)initWithFrame:(CGRect)frame configuration:(SelPlayerConfiguration *)configuration;

/** 播放器配置信息 */
/** 是否是倒计时 */
@property (nonatomic, assign) BOOL isCountDown;
@property (nonatomic, strong) SelPlayerConfiguration *playerConfiguration;
//美数实体
@property (nonatomic, strong) MSAdModel *adModel;

@property (nonatomic, weak) id<SelVideoPlayerDelegate> delegate;

@property (nonatomic, strong)UIViewController *currentViewController;

/** 播放视频 */
- (void)_playVideo;
/** 暂停播放 */
- (void)_pauseVideo;
/** 释放播放器 */
- (void)_deallocPlayer;

@end
