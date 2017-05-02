/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"
#import "SDWebImageDownloaderOperation.h"
#import <ImageIO/ImageIO.h>

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

@interface SDWebImageDownloader ()

@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (weak, nonatomic) NSOperation *lastAddedOperation;
@property (assign, nonatomic) Class operationClass;
@property (strong, nonatomic) NSMutableDictionary *URLCallbacks;
@property (strong, nonatomic) NSMutableDictionary *HTTPHeaders;
// This queue is used to serialize the handling of the network responses of all the download operation in a single queue
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;

@end

@implementation SDWebImageDownloader

+ (void)initialize {
    // MARK: 为了让 SDNetworkActivityIndicator 文件可以不用导入项目中来（如果不需要的话），这里使用了 runtime 的方式来实现动态创建类以及调用方法，如果导入了这个类，就能设置 Network Activity Indicator，如果没有导入，就不用管他，但也能编译通过
    
    // Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    if (NSClassFromString(@"SDNetworkActivityIndicator")) {

        // TODO: 消除警告的方法。这样写是什么意思，为什么这样写就可以消除警告了？ `-performSelector:` 方法为什么会报内存警告的提示？
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop

        // TODO: 为什么要先移除监听呢？
        // Remove observer in case it was previously added.
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStopNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebImageDownloadStopNotification object:nil];
    }
}

    // TODO: 单例的创建。为什么用单例？单例是什么？何时需要用单例？单例怎么实现？
+ (SDWebImageDownloader *)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _operationClass = [SDWebImageDownloaderOperation class]; // TODO: 为什么需要 operationClass 这个属性？
        _shouldDecompressImages = YES;
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;  // TODO: 设置下载 operation 的默认执行顺序（先进先出还是先进后出）
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;  // MARK: 设置 _downloadQueue 的最大并发数
        _URLCallbacks = [NSMutableDictionary new];
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy]; // TODO: 设置请求头，HTTP 请求头相关知识？image相关？
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT); // TODO: 为什么要创建一个并发队列的 barrierQueue
        _downloadTimeout = 15.0;  // MARK: 设置默认下载超时时长 15s
    }
    return self;
}

- (void)dealloc {
    [self.downloadQueue cancelAllOperations];
    SDDispatchQueueRelease(_barrierQueue);
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (value) {
        self.HTTPHeaders[field] = value;
    }
    else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return self.HTTPHeaders[field];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (void)setOperationClass:(Class)operationClass {
    _operationClass = operationClass ?: [SDWebImageDownloaderOperation class];
}

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
    __block SDWebImageDownloaderOperation *operation;
    __weak __typeof(self)wself = self;

    // 1. 保存 progressBlock 和 completedBlock，并创建下载操作
    // MARK: 这里的 callback 设计的很巧妙，实现逻辑分离，提高可读性
    [self addProgressCallback:progressBlock andCompletedBlock:completedBlock forURL:url createCallback:^{
        
        // 2.创建下载请求
        
        NSTimeInterval timeoutInterval = wself.downloadTimeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 15.0;
        }
        

        // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests if told otherwise
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:timeoutInterval]; // MARK: 设置 NSMutableURLRequest 缓存策略
        request.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies); // TODO: ???
        request.HTTPShouldUsePipelining = YES;   // TODO: ????
        if (wself.headersFilter) {
            request.allHTTPHeaderFields = wself.headersFilter(url, [wself.HTTPHeaders copy]); // 通过 block 回调来给外面自定义 header，跟 delegate 其实是一个道理
        }
        else {
            request.allHTTPHeaderFields = wself.HTTPHeaders;
        }
        // 3.创建并配置下载任务 SDWebImageDownloaderOperation
        operation = [[wself.operationClass alloc] initWithRequest:request
                                                          options:options
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             // _1. 回调 progressBlock
                                                             SDWebImageDownloader *sself = wself; // MARK: weak-strong dance
                                                             if (!sself) return;
                                                             __block NSArray *callbacksForURL;
                                                             dispatch_sync(sself.barrierQueue, ^{  // 这里用的是 sync
                                                                 callbacksForURL = [sself.URLCallbacks[url] copy];
                                                             });
                                                             for (NSDictionary *callbacks in callbacksForURL) {
                                                                 SDWebImageDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
                                                                 if (callback) callback(receivedSize, expectedSize);
                                                             }
                                                         }
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            
                                                            
                                                            SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            __block NSArray *callbacksForURL;
                                                            
                                                            // _1. 从 URLCallbacks 中移除 callback
                                                            dispatch_barrier_sync(sself.barrierQueue, ^{ // MARK: 这里用的是 sync
                                                                callbacksForURL = [sself.URLCallbacks[url] copy];
                                                                if (finished) {
                                                                    [sself.URLCallbacks removeObjectForKey:url];
                                                                }
                                                            });
                                                            
                                                            // _2. 回调 completedBlock
                                                            for (NSDictionary *callbacks in callbacksForURL) {
                                                                SDWebImageDownloaderCompletedBlock callback = callbacks[kCompletedCallbackKey];
                                                                if (callback) callback(image, data, error, finished);
                                                            }
                                                        }
                                                        cancelled:^{
                                                            // _1. 从 URLCallbacks 中移除 callback
                                                            SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            dispatch_barrier_async(sself.barrierQueue, ^{
                                                                [sself.URLCallbacks removeObjectForKey:url];
                                                            });
                                                            
                                                            // _2.cancel 掉的没有回调？？
                                                        }];
        // 4.设置下载完成后是否需要解压缩
        operation.shouldDecompressImages = wself.shouldDecompressImages;
        
        // 5.设置 operation 的 credential
        if (wself.username && wself.password) {
            operation.credential = [NSURLCredential credentialWithUser:wself.username password:wself.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        // 6.设置 operation 的优先级
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }

        // 7.开启下载任务，因为 NSOperation 实例只有在手动调用 start 方法或者加入 NSOperationQueue 才会执行
        [wself.downloadQueue addOperation:operation];
        
        // 8.设置下载任务先后顺序
        if (wself.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
            // Emulate LIFO execution order by systematically adding new operations as last operation's dependency
            [wself.lastAddedOperation addDependency:operation]; // TODO: 上一个创建的 operation 要等到最新的 operation 执行完毕才开始执行
            wself.lastAddedOperation = operation;
        }
    }];

    return operation;
}

- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock andCompletedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SDWebImageNoParamsBlock)createCallback {
    
    // 1.错误检查：URL 为空就直接返回
    // The URL will be used as the key to the callbacks dictionary so it cannot be nil. If it is nil immediately call the completed block with no image or data.
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, nil, NO);
        }
        return;
    }

    // 2.保存 progressBlock 和 completedBlock 到 URLCallbacks 中
    dispatch_barrier_sync(self.barrierQueue, ^{  // MARK: 使用 dispatch_barrier_sync 来保证同一时间只有一个线程能对 URLCallbacks 进行操作，实现读写操作之间的隔离
        BOOL first = NO;
        if (!self.URLCallbacks[url]) {
            self.URLCallbacks[url] = [NSMutableArray new];
            first = YES;
        }

        // Handle single download of simultaneous download request for the same URL
        NSMutableArray *callbacksForURL = self.URLCallbacks[url];
        NSMutableDictionary *callbacks = [NSMutableDictionary new]; // 一个 callbacks 里面有一个 progressBlock 和一个 completedBlock
        if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
        if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
        [callbacksForURL addObject:callbacks];     // 添加新的 callbacks
        self.URLCallbacks[url] = callbacksForURL;

        // 3.只在第一次加载这张图片的 url 时，执行下载 block，也就是为了防止重复下载
        if (first) {
            createCallback();
        }
    });
}

    // TODO: 设置 suspended 属性干吗用的？
- (void)setSuspended:(BOOL)suspended {
    [self.downloadQueue setSuspended:suspended];
}

@end
