//
//  SYNetworking.h
//  CC-Store-iOS
//
//  Created by 舒杨 on 2018/4/12.
//  Copyright © 2018年 PayneCai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYRequset;
@class SYDataModel;
@class SYNetworking;
/**
 多个请求成功的回调
 @param array 服务器返回的数据,若是可以转换成相应的model
 */
typedef void(^SYSynResponseBlock)(NSArray <SYDataModel *>*array);

/**
 异步
 多个请求成功的回调
 @param model 服务器返回的数据,若是可以转换成相应的model
 */
typedef void(^SYAsynResponseBlock)(SYDataModel *model);

@interface SYNetworking : NSObject

//获取SYNetworking
+ (SYNetworking *)shareSingle;

/**
 异步请求:以body方式,支持数组
 提供多个网络请求同时请求->完成后一起返回
 @param requests 请求的参数
 @param responseBlock 请求的回调
 */
- (void)sy_asynRequestWithArray:(NSArray <SYRequset *>*)requests responseBlock:(SYAsynResponseBlock)responseBlock;
//同步分别以model传递多次
- (void)sy_synRequestWithArray:(NSArray <SYRequset *>*)requests responseBlock:(SYSynResponseBlock)responseBlock;

//正在运行的网络任务
- (NSArray *)sy_runningRequsetTasks;
//取消SYRequset请求
- (void)sy_cancelRequestWithRequest:(SYRequset *)request;
//取消所有请求
- (void)sy_cancleAllRequest;

@end
