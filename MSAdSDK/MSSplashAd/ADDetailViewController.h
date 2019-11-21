//
//  ADDetailViewController.h
//  启动屏加启动广告页
//
//  Created by WOSHIPM on 16/8/29.
//  Copyright © 2016年 WOSHIPM. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CloseBlock)(void);                                  // 成功返回的数据
@interface ADDetailViewController : UIViewController
@property(nonatomic, copy)NSString *URLString;
@property(nonatomic,copy)CloseBlock closeBlock;
@end
