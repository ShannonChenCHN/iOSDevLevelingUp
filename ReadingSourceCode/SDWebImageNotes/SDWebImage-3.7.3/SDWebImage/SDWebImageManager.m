/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import <objc/message.h>

@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;
@property (strong, nonatomic) NSOperation *cacheOperation;

@end

@interface SDWebImageManager ()

@property (strong, nonatomic, readwrite) SDImageCache *imageCache;
@property (strong, nonatomic, readwrite) SDWebImageDownloader *imageDownloader;
@property (strong, nonatomic) NSMutableSet *failedURLs;
@property (strong, nonatomic) NSMutableArray *runningOperations;

@end

@implementation SDWebImageManager

+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _imageCache = [self createCache];
        _imageDownloader = [SDWebImageDownloader sharedDownloader];
        _failedURLs = [NSMutableSet new];
        _runningOperations = [NSMutableArray new];
    }
    return self;
}

- (SDImageCache *)createCache {
    return [SDImageCache sharedImageCache];
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    }
    else {
        return [url absoluteString];
    }
}

- (BOOL)cachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    if ([self.imageCache imageFromMemoryCacheForKey:key] != nil) return YES;
    return [self.imageCache diskImageExistsWithKey:key];
}

- (BOOL)diskImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    return [self.imageCache diskImageExistsWithKey:key];
}

- (void)cachedImageExistsForURL:(NSURL *)url
                     completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    BOOL isInMemoryCache = ([self.imageCache imageFromMemoryCacheForKey:key] != nil);
    
    if (isInMemoryCache) {
        // making sure we call the completion block on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES);
            }
        });
        return;
    }
    
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

- (void)diskImageExistsForURL:(NSURL *)url
                   completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // the completion block of checkDiskCacheForImageWithKey:completion: is always called on the main queue, no need to further dispatch
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
    // 1.错误检查
    // MARK: SDWebImagePrefetcher 可以用来提前下载图片，但是 option 是 SDWebImageLowPriority
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    // 2.创建 SDWebImageCombinedOperation 对象
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];  // TODO: 1.这里为什么用 __block？2.这个 operation 是用来干嘛的？（①包装一个 cacheOperation，用来追踪硬盘时的 cancel 行为 ② 用来做 cancel 操作）
    __weak SDWebImageCombinedOperation *weakOperation = operation;  // TODO: 为什么用 weak

    // 3.判断是否是曾经下载失败过的 url
    BOOL isFailedUrl = NO;
    @synchronized (self.failedURLs) {  // TODO:
        isFailedUrl = [self.failedURLs containsObject:url];
    }

    // 4.下载失败后再次下载时，如果不是 SDWebImageRetryFailed，就直接回调，并且 return 掉
    if (!url || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, error, SDImageCacheTypeNone, YES, url);
        });
        return operation;
    }

    // 5.添加 operation 到 runningOperations 中
    @synchronized (self.runningOperations) {  // TODO:
        [self.runningOperations addObject:operation];
    }
    
    // 6.读取缓存
    NSString *key = [self cacheKeyForURL:url]; // 缓存用的 key

    operation.cacheOperation = [self.imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        
        // _1.判断是否已经被取消了
        if (operation.isCancelled) { // MARK: 跟使用 AFNetworking 2.x 的网络请求是一个道理，发出去的请求一般不能直接 cancel 掉，只能先做个标记，等到回调时根据 isCancelled 来判断是否被取消掉了
            @synchronized (self.runningOperations) { // TODO: 加锁
                [self.runningOperations removeObject:operation];
            }

            return;
        }

        // _2.1 如果缓存中没有图片或者图片每次都需要更新，那么就根据是否需要下载来做进一步处理
        if ((!image || options & SDWebImageRefreshCached) &&
            (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] ||
             [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
                
                // _2.1.1 如果有缓存图片，先回调 completedBlock，回传缓存的图片
                if (image && options & SDWebImageRefreshCached) {
                    dispatch_main_sync_safe(^{
                        // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                        // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                        completedBlock(image, nil, cacheType, YES, url);
                    });
                }
 
                // _2.1.2 设置 downloaderOptions
                // download if no image or requested to refresh anyway, and download allowed by delegate
                SDWebImageDownloaderOptions downloaderOptions = 0;
                if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;  // MARK: 位运算符操作
                if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
                if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
                if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
                if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
                if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
                if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
                if (image && options & SDWebImageRefreshCached) {
                    // force progressive off if image already cached but forced refreshing
                    downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;  // TODO: 位运算符操作
                    // ignore image read from NSURLCache if image if cached but force refreshing
                    downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
                }
                
                
                // _2.1.3 开始下载图片
                id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *data, NSError *error, BOOL finished) {
                    
                    
                    if (weakOperation.isCancelled) {  // __1.1 操作被取消。TODO: 这里发生了什么
                        // Do nothing if the operation was cancelled
                        // See #699 for more details
                        // if we would call the completedBlock, there could be a race condition between this block and another completedBlock for the same object, so if this one is called second, we will overwrite the new data
                    }
                    else if (error) { // __1.2下载失败
                        
                        // __1.2.1 被取消了，回调 completedBlock.
                        // TODO:
                        dispatch_main_sync_safe(^{
                            if (!weakOperation.isCancelled) {
                                completedBlock(nil, error, SDImageCacheTypeNone, finished, url);
                            }
                        });
                        
                        // __1.2.2 将 URL 加入下载失败的黑名单
                        // TODO: 什么样的失败才能加入 failedURLs？
                        BOOL shouldBeFailedURLAlliOSVersion = (error.code != NSURLErrorNotConnectedToInternet && error.code != NSURLErrorCancelled && error.code != NSURLErrorTimedOut);
                        BOOL shouldBeFailedURLiOS7 = (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && error.code != NSURLErrorInternationalRoamingOff && error.code != NSURLErrorCallIsActive && error.code != NSURLErrorDataNotAllowed);
                        if (shouldBeFailedURLAlliOSVersion || shouldBeFailedURLiOS7) {
                            @synchronized (self.failedURLs) { // MARK: 加锁
                                [self.failedURLs addObject:url];
                            }
                        }
                    }
                    else { // __1.3下载成功
                        // __1.3.1 将 URL 从下载失败的黑名单中移除
                        if ((options & SDWebImageRetryFailed)) {
                            @synchronized (self.failedURLs) {
                                [self.failedURLs removeObject:url];
                            }
                        }
                        
                        BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                        
                        // __1.3.2.1 针对 SDWebImageRefreshCached 和 NSURLCache 的情况不做处理
                        if (options & SDWebImageRefreshCached && image && !downloadedImage) { // TODO: ???
                            // Image refresh hit the NSURLCache cache, do not call the completion block
                        }
                        // __1.3.2.2 需要转图片
                        else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                // __1.3.2.2.1 转换图片
                                UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
                                
                                // __1.3.2.2.2 缓存图片
                                if (transformedImage && finished) {
                                    BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                    [self.imageCache storeImage:transformedImage recalculateFromImage:imageWasTransformed imageData:(imageWasTransformed ? nil : data) forKey:key toDisk:cacheOnDisk];
                                }
                                
                                // __1.3.2.2.3 回调 completedBlock
                                dispatch_main_sync_safe(^{
                                    if (!weakOperation.isCancelled) {
                                        completedBlock(transformedImage, nil, SDImageCacheTypeNone, finished, url);
                                    }
                                });
                            });
                        }
                        else { // __1.3.2.3 不需要转图片
                            
                            // __1.3.2.3.1 缓存图片
                            if (downloadedImage && finished) {
                                [self.imageCache storeImage:downloadedImage recalculateFromImage:NO imageData:data forKey:key toDisk:cacheOnDisk];
                            }
                            // __1.3.2.3.2 回调 completedBlock
                            dispatch_main_sync_safe(^{
                                if (!weakOperation.isCancelled) {
                                    completedBlock(downloadedImage, nil, SDImageCacheTypeNone, finished, url);
                                }
                            });
                        }
                    }
                    
                    // __2. 移除 operation
                    if (finished) {
                        @synchronized (self.runningOperations) {
                            [self.runningOperations removeObject:operation];
                        }
                    }
                }];
                
                // _2.1.4 设置 SDWebImageCombinedOperation 的 cancelBlock
                operation.cancelBlock = ^{ // MARK: cancel 掉 operation 时要把 subOperation 也 cancel 掉，
                    [subOperation cancel];
                    
                    @synchronized (self.runningOperations) {
                        [self.runningOperations removeObject:weakOperation];  // TODO: 为什么要在这里移除 weakOperation 呢，因为当 operation 的 cancel 方法被调用时，cancelBlock 也会被调用
                    }
                };
            }
        else if (image) {  // _2.2 如果有缓存图片且不需要每次更新
            
            // _2.2.1 回调 completedBlock
            dispatch_main_sync_safe(^{
                if (!weakOperation.isCancelled) {
                    completedBlock(image, nil, cacheType, YES, url);
                }
            });
            
            // 流程结束，从 runningOperations 中移除 operation
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
        else { // _2.3 如果没有缓存图片而且不允许下载
            // _2.3.1 回调 completedBlock
            // Image not in cache and download disallowed by delegate
            dispatch_main_sync_safe(^{
                if (!weakOperation.isCancelled) {
                    completedBlock(nil, nil, SDImageCacheTypeNone, YES, url);  // 回调中 image 为 nil
                }
            });
            
            // 流程结束，从 runningOperations 中移除 operation
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
    }];
    
    return operation;
}

- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url {
    if (image && url) {
        NSString *key = [self cacheKeyForURL:url];
        [self.imageCache storeImage:image forKey:key toDisk:YES];
    }
}

- (void)cancelAll {
    @synchronized (self.runningOperations) {
        NSArray *copiedOperations = [self.runningOperations copy];
        [copiedOperations makeObjectsPerformSelector:@selector(cancel)];
        [self.runningOperations removeObjectsInArray:copiedOperations];
    }
}

- (BOOL)isRunning {
    return self.runningOperations.count > 0;
}

@end


@implementation SDWebImageCombinedOperation

- (void)setCancelBlock:(SDWebImageNoParamsBlock)cancelBlock {
    // check if the operation is already cancelled, then we just call the cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        // TODO: 为什么不置为 nil，就会 crash？
        _cancelBlock = nil; // don't forget to nil the cancelBlock, otherwise we will get crashes
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
        
        // TODO: this is a temporary fix to #809.
        // Until we can figure the exact cause of the crash, going with the ivar instead of the setter
//        self.cancelBlock = nil;
        _cancelBlock = nil;
    }
}

@end


@implementation SDWebImageManager (Deprecated)

// deprecated method, uses the non deprecated method
// adapter for the completion block
- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedWithFinishedBlock)completedBlock {
    return [self downloadImageWithURL:url
                              options:options
                             progress:progressBlock
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (completedBlock) {
                                    completedBlock(image, error, cacheType, finished);
                                }
                            }];
}

@end
