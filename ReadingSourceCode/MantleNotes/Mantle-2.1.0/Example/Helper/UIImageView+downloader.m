//
//  UIImageView+downloader.m
//  Example
//
//  Created by ShannonChen on 2017/9/29.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "UIImageView+downloader.h"

@implementation UIImageView (downloader)

- (void)setImageWithURL:(NSURL *)url {
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        self.image = downloadedImage;
    }];
    
    [task resume];

}

@end
