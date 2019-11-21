//
//   MSSDKNetSession.h
//   MSAdSDK
//
//   Created by yang on 2019/8/22.
//   Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>



typedef void(^SuccessBlock)(id response);                                  // 成功返回的数据

typedef void(^RequestHeadBlock)(id response);                               // 请求头返回的数据

typedef void(^FaileBlock)(NSError * error);                              // 请求错误返回的数据

typedef NS_ENUM(NSUInteger,WsqflyNetSessionMaskState) {
          WsqflyNetSessionMaskStateNone      =0,                      // 没有菊花
    
          WsqflyNetSessionMaskStateCanTouch =1,                     // 有菊花并点击屏幕有效
          WsqflyNetSessionMaskStateNotTouch =2   // 有菊花单点击屏幕没有效果

};



typedef NS_ENUM(NSUInteger,WsqflyNetSessionResponseType){
    
          WsqflyNetSessionResponseTypeDATA    =0,               // 返回后台是什么就是什么DATA
          WsqflyNetSessionResponseTypeJSON    =1// 返会序列化后的JSON数据
};







@interface MSSDKNetSession : NSObject

//单利
+ (instancetype) wsqflyNetWorkingShare;

//判断是否有网络
//+ (NSString *)connectedToNetwork;




/**GET短数据请求
 
  * urlString           网址
 
  * param               参数
 
  * state               显示菊花的类型
 
  * backData            返回的数据是NSDATA还是JSON
 
  * successBlock        成功数据的block
 
  * faileBlock          失败的block
 
  * requestHeadBlock   请求头的数据的block
 
  */

- (void)get:(NSString *)urlString param:(NSDictionary *)param maskState:(WsqflyNetSessionMaskState)state backData:(WsqflyNetSessionResponseType)backData success:(SuccessBlock)successBlock requestHead:(RequestHeadBlock)requestHeadBlock faile:(FaileBlock)faileBlock;





/**POST短数据请求
 
  * urlString            网址
 
  * param                 参数
 
  * state                 显示菊花的类型
 
  * backData             返回的数据是NSDATA还是JSON
 
  * successBlock         成功数据的block
 
  * faileBlock           失败的block
 
  * requestHeadBlock    请求头的数据的block
 
  */



-(void)post:(NSString *)urlString bodyparam:(NSDictionary *)param maskState:(WsqflyNetSessionMaskState)state backData:(WsqflyNetSessionResponseType)backData success:(SuccessBlock)successBlock requestHead:(RequestHeadBlock)requestHeadBlock faile:(FaileBlock)faileBlock;


//

//  WsqflyNetWorking.m

//  WSQNetWorkingSystem

//

//  Created by webapps on 16/12/28.

//  Copyright © 2016年 webapps. All rights reserved.

//

@end

