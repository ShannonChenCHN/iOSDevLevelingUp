//
//  NetworkService.h
//  NSURLSessionExample
//
//  Created by ShannonChen on 2018/1/31.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NetworkServiceCallbackType) {
    NetworkServiceCallbackTypeDelegate,
    NetworkServiceCallbackTypeBlock,
};

@interface NetworkService : NSObject

+ (instancetype)serviceWithCallbackType:(NetworkServiceCallbackType)type;

/// 向网络请求数据
- (void)fetchingContentAsData;

/// 文件下载
- (void)downloadingContentAsAFile;


/// 通过提交 form 表单的形式上传文件
- (void)uploadingFormDataUsingAnNSDataObject;

/// 上传本地文件
- (void)uploadingBodyContentUsingAFile;

@end
