//
//  NetworkService.m
//  NSURLSessionExample
//
//  Created by ShannonChen on 2018/1/31.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "NetworkService.h"
#import "_NetworkServiceBlock.h"
#import "_NetworkServiceDelegate.h"

@implementation NetworkService

+ (instancetype)serviceWithCallbackType:(NetworkServiceCallbackType)type {
    if (type == NetworkServiceCallbackTypeDelegate) {
        return [_NetworkServiceDelegate new];
    } else {
        return [_NetworkServiceBlock new];
    }
    
}

/// 向网络请求数据
- (void)fetchingContentAsData {}

/// 文件下载
- (void)downloadingContentAsAFile {}


/// 通过提交 form 表单的形式上传文件
- (void)uploadingFormDataUsingAnNSDataObject {}

/// 上传本地文件
- (void)uploadingBodyContentUsingAFile {}



@end
