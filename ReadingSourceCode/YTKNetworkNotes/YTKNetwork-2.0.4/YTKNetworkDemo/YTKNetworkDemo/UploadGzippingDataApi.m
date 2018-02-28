//
//  UploadGzippingDataApi.m
//  YTKNetworkDemo
//
//  Created by ShannonChen on 2018/2/28.
//  Copyright © 2018年 yuantiku.com. All rights reserved.
//

#import "UploadGzippingDataApi.h"

@implementation UploadGzippingDataApi


- (NSString *)requestUrl {
    return @"/iphone/gzipping/upload";
}


/// 定制 URL Request
- (NSURLRequest *)buildCustomUrlRequest {
    
    NSData *gzippingData = [NSData data]; // 假数据
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setHTTPBody:gzippingData];
    
    return request;
}


@end
