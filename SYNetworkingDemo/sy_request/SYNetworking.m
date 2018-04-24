//
//  SYNetworking.m
//  CC-Store-iOS
//
//  Created by 舒杨 on 2018/4/12.
//  Copyright © 2018年 PayneCai. All rights reserved.
//

#import "SYNetworking.h"
#import "AFNetworking.h"
#import "SYRequset.h"
#import "SYDataModel.h"

@interface SYNetworking ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
//请求任务池
@property (nonatomic, strong) NSMutableArray *requestTasksPools;

@end


@implementation SYNetworking

+ (SYNetworking *)shareSingle
{
    static dispatch_once_t onceToken;
    static SYNetworking *rq;
    dispatch_once(&onceToken, ^{
        rq = [[SYNetworking alloc] init];
    });
    return rq;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.manager= [AFHTTPSessionManager manager];
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
        
    }
    return self;
}

/**
 异步请求:以body方式,支持数组
 提供多个网络请求同时请求->完成多有请求后返回
 */
- (void)sy_asynRequestWithArray:(NSArray <SYRequset *>*)requests responseBlock:(SYAsynResponseBlock)responseBlock {
    [self sy_Requests:requests isAsyn:YES response_Asyn:responseBlock response_Syn:nil];
}
//同步
- (void)sy_synRequestWithArray:(NSArray <SYRequset *>*)requests responseBlock:(SYSynResponseBlock)responseBlock {
    [self sy_Requests:requests isAsyn:NO response_Asyn:nil response_Syn:responseBlock];
}

//异步网络请求
-(void)sy_Requests:(NSArray<SYRequset *> *)requests isAsyn:(BOOL)isAsyn response_Asyn:(SYAsynResponseBlock)response_Asyn response_Syn:(SYSynResponseBlock)response_Syn {


    //创建信号量
    dispatch_semaphore_t sem;
    if (!isAsyn) {
        sem = dispatch_semaphore_create(0);
        //解决死锁问题
        _manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }

    //创建返回的数组
    NSMutableArray <SYDataModel *>*successArray = [NSMutableArray array];

    for (SYRequset *request in requests) {

        if (!request) {
            return;
        }
        //请求地址
        NSString *url = request.requestUrl;
        
        //请求地址参数
        id parms = request.parms;

        //配置请求信息
        NSMutableURLRequest *req = [self sy_requestWithMethod:request.requestMethod Url:url Parms:parms];

        //返回信息
        __block SYAsynResponseBlock res_asyn = response_Asyn;

        
        //开始请求
       __block NSURLSessionTask *task = [_manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
       } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
       } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

            SYDataModel *responseModel;

            if (!error) {
                
                #warning 转模型
//              responseModel = [SYDataModel mj_objectWithKeyValues:responseObject];
                responseModel = [[SYDataModel alloc]init];
                responseModel.data = responseObject;//简单处理
                //请求成功
                if (isAsyn) {//异步的直接传送数据
                    #pragma mark - 主线程传送数据
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //传输数据
                        if (res_asyn) {
                            res_asyn(responseModel);
                        }
                    });
                    
                }else{
                    //添加到数组
                    [successArray addObject:responseModel];
                }

            } else {
                responseModel = [[SYDataModel alloc]init];
                responseModel.err = error;
                //请求失败
                if (isAsyn) {
                    #pragma mark - 主线程传送数据
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //传输数据
                        if (res_asyn) {
                            res_asyn(responseModel);
                        }
                    });
                }else{
                    SYDataModel *responseModel = [[SYDataModel alloc]init];
                    responseModel.err = error;
                    [successArray addObject:responseModel];
                }
            }
            //赋值request
            responseModel.request = request;
           
           //请求结束，移除task
           if ([self.requestTasksPools containsObject:task]) {
               [self.requestTasksPools removeObject:task];
           }
           if (!isAsyn) {
                dispatch_semaphore_signal(sem);
            }

        }];

        //
        [task resume];
        [self.requestTasksPools addObject:task];
        if (!isAsyn) {
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }

    }

    #pragma mark - 主线程传送数据
    dispatch_async(dispatch_get_main_queue(), ^{
        //传输数据
        if (response_Syn) {
            response_Syn(successArray);
        }
    });

}

-(NSMutableURLRequest *)sy_requestWithMethod:(SYRequestMethod)method Url:(NSString *)url Parms:(id)parms {
    
    NSMutableURLRequest *req;
    NSString *methodString;
    //请求方式
    switch (method) {
        case SYRequestMethodGET:
            methodString = @"GET";
            req = [self ConfigureGetRequestMethod:methodString Url:url Parms:parms];
            break;
        case SYRequestMethodPOST:
            methodString = @"POST";
            req = [self ConfigureOtherRequestMethod:methodString Url:url Parms:parms];
            break;
            
        case SYRequestMethodHEAD:
            methodString = @"HEAD";
            req = [self ConfigureOtherRequestMethod:methodString Url:url Parms:parms];
            break;
            
        case SYRequestMethodPUT:
            methodString = @"PUT";
            req = [self ConfigureOtherRequestMethod:methodString Url:url Parms:parms];
            break;
            
        case SYRequestMethodDELETE:
            methodString = @"DELETE";
            req = [self ConfigureOtherRequestMethod:methodString Url:url Parms:parms];
            break;
            
        case SYRequestMethodPATCH:
            methodString = @"PATCH";
            req = [self ConfigureOtherRequestMethod:methodString Url:url Parms:parms];
            break;
            
        default:
            break;
    }
    
    return req;
    
}

-(NSMutableURLRequest *)ConfigureGetRequestMethod:(NSString *)method Url:(NSString *)url Parms:(id)parms {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    
    request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:parms error:nil];
    request.timeoutInterval= 10;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    #pragma mark - 其他设置
    //请求的头部信息；（我们执行网络请求的时候给服务器发送的包头信息）
    //[request setValue:sign forHTTPHeaderField:@"sign"];
    
    return request;
}

-(NSMutableURLRequest *)ConfigureOtherRequestMethod:(NSString *)method Url:(NSString *)url Parms:(id)parms {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    
    request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:nil error:nil];
    NSString *param= [self convertToJsonData:parms]; // [parms mj_JSONString]
    request.timeoutInterval= 10;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding];
    // 设置body
    [request setHTTPBody:postData];
    
    #pragma mark - 其他设置
    //请求的头部信息；（我们执行网络请求的时候给服务器发送的包头信息）
    //[request setValue:sign forHTTPHeaderField:@"sign"];
    return request;
}


//正在运行的网络任务
- (NSArray *)sy_runningRequsetTasks {
    return [self.requestTasksPools mutableCopy];
}
//取消SYRequset请求
- (void)sy_cancelRequestWithRequest:(SYRequset *)request {
    //请求地址
    NSString *url = request.requestUrl;
    if (!url) return;
    @synchronized (self) {
        [self.requestTasksPools enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }

}
//取消所有请求
- (void)sy_cancleAllRequest {
    
    @synchronized (self) {
        [self.requestTasksPools enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [self.requestTasksPools removeAllObjects];
    }

}

-(NSMutableArray *)requestTasksPools
{
    if (!_requestTasksPools) {
        _requestTasksPools = [NSMutableArray array];
    }
    return _requestTasksPools;
}

#pragma mark - dict->json  可以用MJ的
-(NSString *)convertToJsonData:(id)dic

{
    
    NSDictionary *dict = (NSDictionary *)dic;
    NSError *error;
    
    if (dict == nil) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return jsonString;
    
}

@end
