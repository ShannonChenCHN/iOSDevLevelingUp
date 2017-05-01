//
//  UIImageView+YYWebImage.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIImageView+YYWebImage.h"
#import "YYWebImageOperation.h"
#import "_YYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface UIImageView_YYWebImage : NSObject @end
@implementation UIImageView_YYWebImage @end

static int _YYWebImageSetterKey;
static int _YYWebImageHighlightedSetterKey;


@implementation UIImageView (YYWebImage)

#pragma mark - image

- (NSURL *)yy_imageURL {
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageSetterKey);
    return setter.imageURL;
}

- (void)setYy_imageURL:(NSURL *)imageURL {
    [self yy_setImageWithURL:imageURL
                 placeholder:nil
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL options:(YYWebImageOptions)options {
    [self yy_setImageWithURL:imageURL
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(YYWebImageOptions)options
                completion:(YYWebImageCompletionBlock)completion {
    [self yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(YYWebImageOptions)options
                  progress:(YYWebImageProgressBlock)progress
                 transform:(YYWebImageTransformBlock)transform
                completion:(YYWebImageCompletionBlock)completion {
    [self yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(YYWebImageOptions)options
                   manager:(YYWebImageManager *)manager
                  progress:(YYWebImageProgressBlock)progress
                 transform:(YYWebImageTransformBlock)transform
                completion:(YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [YYWebImageManager sharedManager];
    
    // 获取 _YYWebImageSetter
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageSetterKey);
    if (!setter) {
        setter = [_YYWebImageSetter new];
        objc_setAssociatedObject(self, &_YYWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 取消 imageView 当前的加载，返回状态标记
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _yy_dispatch_sync_on_main_queue(^{
        // 先移除原来的动画
        if ((options & YYWebImageOptionSetImageWithFadeAnimation) &&
            !(options & YYWebImageOptionAvoidSetImage)) {
            if (!self.highlighted) {
                [self.layer removeAnimationForKey:_YYWebImageFadeAnimationKey];
            }
        }
        
        // 图片 URL 为空，设置占位图，再 return
        // MARK: 为什么没有回调？
        if (!imageURL) {
            if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
                self.image = placeholder;
            }
            return;
        }
        
        // 【快速】读取内存缓存，如果有缓存，就直接回调、return了
        // MARK: 为什么 YYWebImage 读取的缓存策略跟 SDWebImage 不一样呢？
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & YYWebImageOptionUseNSURLCache) &&
            !(options & YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & YYWebImageOptionAvoidSetImage)) {
                self.image = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, YYWebImageFromMemoryCacheFast, YYWebImageStageFinished, nil);
            return;
        }
        
        // 下载前设置占位图
        if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
            self.image = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_YYWebImageSetter setterQueue], ^{ // 创建队列 serial queue， 开启异步任务
            // progress block 回调
            YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            // completion block 回调
            __block int32_t newSentinel = 0; // 初始时为 0
            __block __weak typeof(setter) weakSetter = nil;  // MARK: 同时加了 __block 和 __weak 时，block 内部实现是什么样的？
            YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self; // MARK: weak-strong dance
                
                BOOL setImage = (stage == YYWebImageStageFinished || stage == YYWebImageStageProgress) && image && !(options & YYWebImageOptionAvoidSetImage);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel; // TODO: 为什么这里要比较 sentinel 和 newSentinel？是用来判断是否取消的？
                    
                    // 如果需要设置图片，self 没被销毁，sentinel 标记也没有改变（也就是任务没有被取消）的话，就设置图片
                    if (setImage && self && !sentinelChanged) {
                        
                        // 过渡动画
                        BOOL showFade = ((options & YYWebImageOptionSetImageWithFadeAnimation) && !self.highlighted);
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == YYWebImageStageFinished ? _YYWebImageFadeTime : _YYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_YYWebImageFadeAnimationKey];
                        }
                        
                        // 设置图片
                        self.image = image;
                    }
                    
                    // completion block 的回调
                    if (completion) {
                        if (sentinelChanged) { // 被取消了
                            completion(nil, url, YYWebImageFromNone, YYWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            // 开启一个加载任务
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter; // TODO：这里为什么要将 setter 赋值给 weakSetter？？？
        });
    });
}

- (void)yy_cancelCurrentImageRequest {
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageSetterKey);
    if (setter) [setter cancel];
}


#pragma mark - highlighted image

- (NSURL *)yy_highlightedImageURL {
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageHighlightedSetterKey);
    return setter.imageURL;
}

- (void)setYy_highlightedImageURL:(NSURL *)imageURL {
    [self yy_setHighlightedImageWithURL:imageURL
                            placeholder:nil
                                options:kNilOptions
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:nil];
}

- (void)yy_setHighlightedImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self yy_setHighlightedImageWithURL:imageURL
                            placeholder:placeholder
                                options:kNilOptions
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:nil];
}

- (void)yy_setHighlightedImageWithURL:(NSURL *)imageURL options:(YYWebImageOptions)options {
    [self yy_setHighlightedImageWithURL:imageURL
                            placeholder:nil
                                options:options
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:nil];
}

- (void)yy_setHighlightedImageWithURL:(NSURL *)imageURL
                          placeholder:(UIImage *)placeholder
                              options:(YYWebImageOptions)options
                           completion:(YYWebImageCompletionBlock)completion {
    [self yy_setHighlightedImageWithURL:imageURL
                            placeholder:placeholder
                                options:options
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:completion];
}

- (void)yy_setHighlightedImageWithURL:(NSURL *)imageURL
                          placeholder:(UIImage *)placeholder
                              options:(YYWebImageOptions)options
                             progress:(YYWebImageProgressBlock)progress
                            transform:(YYWebImageTransformBlock)transform
                           completion:(YYWebImageCompletionBlock)completion {
    [self yy_setHighlightedImageWithURL:imageURL
                            placeholder:placeholder
                                options:options
                                manager:nil
                               progress:progress
                              transform:nil
                             completion:completion];
}

- (void)yy_setHighlightedImageWithURL:(NSURL *)imageURL
                          placeholder:(UIImage *)placeholder
                              options:(YYWebImageOptions)options
                              manager:(YYWebImageManager *)manager
                             progress:(YYWebImageProgressBlock)progress
                            transform:(YYWebImageTransformBlock)transform
                           completion:(YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [YYWebImageManager sharedManager];
    
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageHighlightedSetterKey);
    if (!setter) {
        setter = [_YYWebImageSetter new];
        objc_setAssociatedObject(self, &_YYWebImageHighlightedSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _yy_dispatch_sync_on_main_queue(^{
        if ((options & YYWebImageOptionSetImageWithFadeAnimation) &&
            !(options & YYWebImageOptionAvoidSetImage)) {
            if (self.highlighted) {
                [self.layer removeAnimationForKey:_YYWebImageFadeAnimationKey];
            }
        }
        if (!imageURL) {
            if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
                self.highlightedImage = placeholder;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & YYWebImageOptionUseNSURLCache) &&
            !(options & YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & YYWebImageOptionAvoidSetImage)) {
                self.highlightedImage = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, YYWebImageFromMemoryCacheFast, YYWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & YYWebImageOptionIgnorePlaceHolder)) {
            self.highlightedImage = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_YYWebImageSetter setterQueue], ^{
            YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == YYWebImageStageFinished || stage == YYWebImageStageProgress) && image && !(options & YYWebImageOptionAvoidSetImage);
                BOOL showFade = ((options & YYWebImageOptionSetImageWithFadeAnimation) && self.highlighted);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == YYWebImageStageFinished ? _YYWebImageFadeTime : _YYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_YYWebImageFadeAnimationKey];
                        }
                        self.highlightedImage = image;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, YYWebImageFromNone, YYWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)yy_cancelCurrentHighlightedImageRequest {
    _YYWebImageSetter *setter = objc_getAssociatedObject(self, &_YYWebImageHighlightedSetterKey);
    if (setter) [setter cancel];
}

@end
