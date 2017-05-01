//
//  _YYWebImageSetter.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/7/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "_YYWebImageSetter.h"
#import "YYWebImageOperation.h"
#import <libkern/OSAtomic.h>

NSString *const _YYWebImageFadeAnimationKey = @"YYWebImageFade";
const NSTimeInterval _YYWebImageFadeTime = 0.2;
const NSTimeInterval _YYWebImageProgressiveFadeTime = 0.4;


@implementation _YYWebImageSetter {
    dispatch_semaphore_t _lock;
    NSURL *_imageURL;
    NSOperation *_operation;
    int32_t _sentinel;
}

- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1); // 初始值为 1
    return self;
}

- (NSURL *)imageURL {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSURL *imageURL = _imageURL;
    dispatch_semaphore_signal(_lock);
    return imageURL;
}

- (void)dealloc {
    OSAtomicIncrement32(&_sentinel);
    [_operation cancel];
}

- (int32_t)setOperationWithSentinel:(int32_t)sentinel
                                url:(NSURL *)imageURL
                            options:(YYWebImageOptions)options
                            manager:(YYWebImageManager *)manager
                           progress:(YYWebImageProgressBlock)progress
                          transform:(YYWebImageTransformBlock)transform
                         completion:(YYWebImageCompletionBlock)completion {
    // MARK：这里为什么要判断是否被取消？
    if (sentinel != _sentinel) {
        if (completion) completion(nil, imageURL, YYWebImageFromNone, YYWebImageStageCancelled, nil);
        return _sentinel;
    }
    
    // 将图片请求任务交给 YYWebImageManager
    NSOperation *operation = [manager requestImageWithURL:imageURL options:options progress:progress transform:transform completion:completion];
    
    // operation 创建失败，回调 completion
    if (!operation && completion) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"YYWebImageOperation create failed." };
        completion(nil, imageURL, YYWebImageFromNone, YYWebImageStageFinished, [NSError errorWithDomain:@"com.ibireme.webimage" code:-1 userInfo:userInfo]);
    }
    
    // MARK：防止资源竞争
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); // 一直等待，直到 semaphore 计数值大于或等于 1 时或者等待超时；并且等待结束时，会将 semaphore 计数值减 1
    if (sentinel == _sentinel) {
        if (_operation) [_operation cancel];
        _operation = operation;
        sentinel = OSAtomicIncrement32(&_sentinel);
    } else {
        [operation cancel];
    }
    dispatch_semaphore_signal(_lock); // 排他控制结束，semaphore 计数值加 1
    return sentinel;
}

- (int32_t)cancel {
    return [self cancelWithNewURL:nil];
}

- (int32_t)cancelWithNewURL:(NSURL *)imageURL {
    int32_t sentinel;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_operation) {
        [_operation cancel];
        _operation = nil;
    }
    _imageURL = imageURL;
    sentinel = OSAtomicIncrement32(&_sentinel);
    dispatch_semaphore_signal(_lock);
    return sentinel;
}

+ (dispatch_queue_t)setterQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ibireme.webimage.setter", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return queue;
}

@end
