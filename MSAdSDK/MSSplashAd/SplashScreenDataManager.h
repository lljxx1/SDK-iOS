//
//  SplashScreenDataManager.h
//  启动屏加启动广告页
//
//  Created by WOSHIPM on 16/8/29.
//  Copyright © 2016年 WOSHIPM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^SuccessBlock)(id data);
typedef void(^FailBlock)(NSError *error);

@interface SplashScreenDataManager : NSObject
@property(nonatomic, strong)NSArray *resultArray;
@property(nonatomic, strong) NSString *documentPath;
@property(nonatomic, strong) UIImageView *splashImageVeiw;
@property(nonatomic, copy)NSString *imageURL;

+ (void)downloadAdImageWithUrl:(NSString *)imageUrl
                     imageName:(NSString *)imageName
                    imgLinkUrl:(NSString *)imgLinkUrl
                   imgDeadline:(NSString *)imgDeadline
                       success:(SuccessBlock)successBlock
                          fail:(FailBlock)failBlock;

+ (BOOL)isFileExistWithFilePath:(NSString *)filePath;

+(void)getAdvertisingImageDataImageWithUrl:(NSString *)imageUrl
                                imgLinkUrl:(NSString *)imgLinkUrl
                                   success:(SuccessBlock)successBlock
                                      fail:(FailBlock)failBlock;

+ (NSString *)getFilePathWithImageName:(NSString *)imageName;
@end
