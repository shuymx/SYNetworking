//
//  ViewController.m
//  SYNetworkingDemo
//
//  Created by 舒杨 on 2018/4/16.
//  Copyright © 2018年 舒杨. All rights reserved.
//

#import "ViewController.h"
#import "SYNetworking.h"
#import "SYRequset.h"
#import "SYDataModel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *sysButton;
@property (weak, nonatomic) IBOutlet UIButton *asysButton;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //同步请求
    [self.sysButton addTarget:self action:@selector(synNetmorking) forControlEvents:UIControlEventTouchUpInside];
    
    //异步请求
    [self.asysButton addTarget:self action:@selector(asynNetmorking) forControlEvents:UIControlEventTouchUpInside];

    
//    //正在运行的网络任务
//    NSArray *tasks = [[SYNetworking shareSingle] sy_runningRequsetTasks];
//    NSLog(@"%@",tasks);
//
//    //取消网络请求
//    [[SYNetworking shareSingle] sy_cancelRequestWithRequest:request1];
//    [[SYNetworking shareSingle] sy_cancleAllRequest];

    
    // Do any additional setup after loading the view, typically from a nib.
}

//同步请求
-(void)synNetmorking {
    
    SYRequset *request1 = [[SYRequset alloc]init];
    request1.requestUrl = @"http://httpbin.org/get?name=15&age=1";
    request1.requestMethod = SYRequestMethodGET;
    request1.parms = nil;
    
    SYRequset *request2 = [[SYRequset alloc]init];
    request2.requestUrl = @"http://httpbin.org/get?name=name2&age=2";
    request2.requestMethod = SYRequestMethodGET;
    request2.parms = nil;
    
    SYRequset *request3 = [[SYRequset alloc]init];
    request3.requestUrl = @"http://httpbin.org/get?name=name3&age=3";
    request3.requestMethod = SYRequestMethodGET;
    request3.parms = nil;
    
    //request1,request2,request3 按顺序返回
    [[SYNetworking shareSingle] sy_synRequestWithArray:@[request1,request2,request3] responseBlock:^(NSArray<SYDataModel *> *array) {
        
        for (SYDataModel *dataModel in array) {
            
            if (dataModel.request == request1) {
                if (dataModel.err) {
                    //error处理
                    return;
                }
                //处理数据
                NSLog(@"%@",dataModel.data);
            }
            
            if (dataModel.request == request2) {
                if (dataModel.err) {
                    //error处理
                    return;
                }
                //处理数据
                NSLog(@"%@",dataModel.data);

            }
            
            if (dataModel.request == request3) {
                if (dataModel.err) {
                    //error处理
                    return;
                }
                //处理数据
                NSLog(@"%@",dataModel.data);

            }
            
            
        }
    }];

    
}

//异步请求
-(void)asynNetmorking {
    
    SYRequset *request1 = [[SYRequset alloc]init];
    request1.requestUrl = @"http://httpbin.org/post";
    request1.requestMethod = SYRequestMethodPOST;
    request1.parms = @{@"name":@"name1",@"age":@"1"};
    
    SYRequset *request2 = [[SYRequset alloc]init];
    request2.requestUrl = @"http://httpbin.org/post";
    request2.requestMethod = SYRequestMethodPOST;
    request2.parms = @{@"name":@"name2",@"age":@"2"};;
    
    SYRequset *request3 = [[SYRequset alloc]init];
    request3.requestUrl = @"http://httpbin.org/post";
    request3.requestMethod = SYRequestMethodPOST;
    request3.parms = @{@"name":@"name3",@"age":@"3"};
    
    //request1,request2,request3 不按顺序返回
    [[SYNetworking shareSingle] sy_asynRequestWithArray:@[request1,request2,request3] responseBlock:^(SYDataModel *model) {
        
        if (model.request == request1) {
            if (model.err) {
                //error处理
                return;
            }
            //处理数据
            NSLog(@"%@",model.data);
        }
        
        if (model.request == request2) {
            if (model.err) {
                //error处理
                return;
            }
            //处理数据
            NSLog(@"%@",model.data);
        }

        if (model.request == request3) {
            if (model.err) {
                //error处理
                return;
            }
            //处理数据
            NSLog(@"%@",model.data);
        }

        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
