//
//  SYRequset.h
//  CC-Store-iOS
//
//  Created by 舒杨 on 2018/4/12.
//  Copyright © 2018年 PayneCai. All rights reserved.
//

#import <Foundation/Foundation.h>

//请求类型
typedef NS_ENUM (NSInteger, SYRequestMethod){
    
    SYRequestMethodGET          = 0,
    SYRequestMethodPOST         = 1,
    SYRequestMethodHEAD         = 3,
    SYRequestMethodPUT          = 4,
    SYRequestMethodDELETE       = 5,
    SYRequestMethodPATCH        = 6,

};

@interface SYRequset : NSObject

/**请求地址requestUrl*/
@property (nonatomic, copy) NSString *requestUrl;
/**请求方式requestMethod*/
@property (nonatomic, assign) SYRequestMethod requestMethod;
/**传参array、dict、nil等*/
@property (nonatomic, strong) id parms;

/***/
@property (nonatomic, assign) NSInteger index;

@end
