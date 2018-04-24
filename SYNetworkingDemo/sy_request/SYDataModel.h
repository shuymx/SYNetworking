//
//  SYDataModel.h
//  CC-Store-iOS
//
//  Created by 舒杨 on 2018/4/12.
//  Copyright © 2018年 PayneCai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYRequset;

@interface SYDataModel : NSObject

#pragma mark - 返回结果
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) id data;

#pragma mark - *******
/**请求参数*/
@property (nonatomic, strong) SYRequset *request;
/**请求错误*/
@property (nonatomic, strong) NSError *err;

@end
