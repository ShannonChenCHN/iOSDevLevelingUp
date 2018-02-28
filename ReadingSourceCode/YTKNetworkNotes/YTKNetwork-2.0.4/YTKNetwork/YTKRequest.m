//
//  YTKRequest.m
//
//  Copyright (c) 2012-2016 YTKNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "YTKNetworkConfig.h"
#import "YTKRequest.h"
#import "YTKNetworkPrivate.h"

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif

NSString *const YTKRequestCacheErrorDomain = @"com.yuantiku.request.caching";

static dispatch_queue_t ytkrequest_cache_writing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.yuantiku.ytkrequest.caching", attr);
    });

    return queue;
}

@interface YTKCacheMetadata : NSObject<NSSecureCoding>

@property (nonatomic, assign) long long version;                // 缓存版本，因为 api 的返回值可能数据结构有更新，所以 cache 的数据虽没有过期但已经不能用了。这个属性的值一般取自服务端返回数据中的某个字段的，重载 YTKRequest 的 -cacheVersion 方法时带上，如果 cacheVersion 和上次不一样，就会发请求。
@property (nonatomic, strong) NSString *sensitiveDataString;    // 敏感数据，cacheSensitiveData 是在 cacheVersion 的基础上，再加上一些敏感数据，例如，加上 userId，这样当 userId 变化的时候，即使 cacheVersion 没有变，也会重新发请求
@property (nonatomic, assign) NSStringEncoding stringEncoding;  // 编码方式
@property (nonatomic, strong) NSDate *creationDate;             // 创建时间
@property (nonatomic, strong) NSString *appVersionString;       // APP 版本

@end

@implementation YTKCacheMetadata

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.sensitiveDataString forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    [aCoder encodeObject:@(self.stringEncoding) forKey:NSStringFromSelector(@selector(stringEncoding))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }

    self.version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
    self.sensitiveDataString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    self.stringEncoding = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(stringEncoding))] integerValue];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];

    return self;
}

@end

@interface YTKRequest()

@property (nonatomic, strong) NSData *cacheData;
@property (nonatomic, strong) NSString *cacheString;
@property (nonatomic, strong) id cacheJSON;
@property (nonatomic, strong) NSXMLParser *cacheXML;

@property (nonatomic, strong) YTKCacheMetadata *cacheMetadata;
@property (nonatomic, assign) BOOL dataFromCache;

@end

@implementation YTKRequest

- (void)start {
    // 是否忽略缓存，默认是 NO
    if (self.ignoreCache) {
        // 开始请求
        [self startWithoutCache];
        return;
    }

    // Do not cache download request.
    // 下载的请求不需要缓存
    if (self.resumableDownloadPath) {
        [self startWithoutCache];
        return;
    }

    // 读取缓存
    if (![self loadCacheWithError:nil]) {
        [self startWithoutCache];
        return;
    }

    _dataFromCache = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestCompletePreprocessor]; // 请求成功时的预处理，包括写入缓存等
        [self requestCompleteFilter];       // 请求成功时的自定义处理，可重写该方法
        
        // 回调，先回调代理，再回调 block
        YTKRequest *strongSelf = self;
        [strongSelf.delegate requestFinished:strongSelf];
        if (strongSelf.successCompletionBlock) {
            strongSelf.successCompletionBlock(strongSelf);
        }
        
        // 清空 block，打破循环引用
        [strongSelf clearCompletionBlock];
    });
}

- (void)startWithoutCache {
    [self clearCacheVariables];
    [super start];
}

#pragma mark - Network Request Delegate

/// 请求成功后的预处理
- (void)requestCompletePreprocessor {
    [super requestCompletePreprocessor];

    // 写入缓存
    if (self.writeCacheAsynchronously) {
        dispatch_async(ytkrequest_cache_writing_queue(), ^{
            [self saveResponseDataToCacheFile:[super responseData]];
        });
    } else {
        [self saveResponseDataToCacheFile:[super responseData]];
    }
}

#pragma mark - Subclass Override

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (long long)cacheVersion {
    return 0;
}

- (id)cacheSensitiveData {
    return nil;
}

- (BOOL)writeCacheAsynchronously {
    return YES;
}

#pragma mark -

- (BOOL)isDataFromCache {
    return _dataFromCache;
}

- (NSData *)responseData {
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseData];
}

- (NSString *)responseString {
    if (_cacheString) {
        return _cacheString;
    }
    return [super responseString];
}

- (id)responseJSONObject {
    if (_cacheJSON) {
        return _cacheJSON;
    }
    return [super responseJSONObject];
}

- (id)responseObject {
    if (_cacheJSON) {
        return _cacheJSON;
    }
    if (_cacheXML) {
        return _cacheXML;
    }
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseObject];
}

#pragma mark -

- (BOOL)loadCacheWithError:(NSError * _Nullable __autoreleasing *)error {
    // Make sure cache time in valid.
    // cacheTimeInSeconds 默认是 -1，小于 0 时代表不缓存
    if ([self cacheTimeInSeconds] < 0) {
        if (error) {
            *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorInvalidCacheTime userInfo:@{ NSLocalizedDescriptionKey:@"Invalid cache time"}];
        }
        return NO;
    }

    // Try load metadata.
    // 加载元数据缓存
    if (![self loadCacheMetadata]) {
        if (error) {
            *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorInvalidMetadata userInfo:@{ NSLocalizedDescriptionKey:@"Invalid metadata. Cache may not exist"}];
        }
        return NO;
    }

    // Check if cache is still valid.
    // 检查缓存有效性
    if (![self validateCacheWithError:error]) {
        return NO;
    }

    // Try load cache.
    // 加载缓存内容数据
    if (![self loadCacheData]) {
        if (error) {
            *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorInvalidCacheData userInfo:@{ NSLocalizedDescriptionKey:@"Invalid cache data"}];
        }
        return NO;
    }

    return YES;
}

- (BOOL)validateCacheWithError:(NSError * _Nullable __autoreleasing *)error {
    // Date
    NSDate *creationDate = self.cacheMetadata.creationDate;
    NSTimeInterval duration = -[creationDate timeIntervalSinceNow];
    if (duration < 0 || duration > [self cacheTimeInSeconds]) {
        if (error) {
            *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorExpired userInfo:@{ NSLocalizedDescriptionKey:@"Cache expired"}];
        }
        return NO;
    }
    // Version
    // 因为 api 的返回值可能数据结构有更新，所以 cache 的数据虽没有过期但已经不能用了。这个属性的值一般取自服务端返回数据中的某个字段的，重载 YTKRequest 的 -cacheVersion 方法时带上，如果 cacheVersion 和上次不一样，就会发请求。
    long long cacheVersionFileContent = self.cacheMetadata.version;
    if (cacheVersionFileContent != [self cacheVersion]) {
        if (error) {
            *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"Cache version mismatch"}];
        }
        return NO;
    }
    // Sensitive data
    // cacheSensitiveData 是在 cacheVersion 的基础上，再加上一些敏感数据，例如，加上 userId，这样当 userId 变化的时候，即使 cacheVersion 没有变，也会重新发请求
    NSString *sensitiveDataString = self.cacheMetadata.sensitiveDataString;
    NSString *currentSensitiveDataString = ((NSObject *)[self cacheSensitiveData]).description;
    if (sensitiveDataString || currentSensitiveDataString) {
        // If one of the strings is nil, short-circuit evaluation will trigger
        if (sensitiveDataString.length != currentSensitiveDataString.length || ![sensitiveDataString isEqualToString:currentSensitiveDataString]) {
            if (error) {
                *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorSensitiveDataMismatch userInfo:@{ NSLocalizedDescriptionKey:@"Cache sensitive data mismatch"}];
            }
            return NO;
        }
    }
    
    // App version
    NSString *appVersionString = self.cacheMetadata.appVersionString;
    NSString *currentAppVersionString = [YTKNetworkUtils appVersionString];
    if (appVersionString || currentAppVersionString) {
        if (appVersionString.length != currentAppVersionString.length || ![appVersionString isEqualToString:currentAppVersionString]) {
            if (error) {
                *error = [NSError errorWithDomain:YTKRequestCacheErrorDomain code:YTKRequestCacheErrorAppVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"App version mismatch"}];
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)loadCacheMetadata {
    NSString *path = [self cacheMetadataFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        // MARK: 这里为什么用 try-catch ？
        @try {
            _cacheMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            return YES;
        } @catch (NSException *exception) {
            YTKLog(@"Load cache metadata failed, reason = %@", exception.reason);
            return NO;
        }
    }
    return NO;
}

- (BOOL)loadCacheData {
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        _cacheData = data;
        _cacheString = [[NSString alloc] initWithData:_cacheData encoding:self.cacheMetadata.stringEncoding];
        switch (self.responseSerializerType) {
            case YTKResponseSerializerTypeHTTP:
                // Do nothing.
                return YES;
            case YTKResponseSerializerTypeJSON:
                _cacheJSON = [NSJSONSerialization JSONObjectWithData:_cacheData options:(NSJSONReadingOptions)0 error:&error];
                return error == nil;
            case YTKResponseSerializerTypeXMLParser:
                _cacheXML = [[NSXMLParser alloc] initWithData:_cacheData];
                return YES;
        }
    }
    return NO;
}

// 缓存数据
- (void)saveResponseDataToCacheFile:(NSData *)data {
    // cacheTimeInSeconds 大于 0 时，并且是接口返回的数据
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        if (data != nil) {
            @try {
                // New data will always overwrite old data.
                // 覆盖旧的数据
                [data writeToFile:[self cacheFilePath] atomically:YES];

                // 保存缓存相关的元数据
                YTKCacheMetadata *metadata = [[YTKCacheMetadata alloc] init];
                metadata.version = [self cacheVersion];
                metadata.sensitiveDataString = ((NSObject *)[self cacheSensitiveData]).description;
                metadata.stringEncoding = [YTKNetworkUtils stringEncodingWithRequest:self];
                metadata.creationDate = [NSDate date];
                metadata.appVersionString = [YTKNetworkUtils appVersionString];
                [NSKeyedArchiver archiveRootObject:metadata toFile:[self cacheMetadataFilePath]];
            } @catch (NSException *exception) {
                YTKLog(@"Save cache failed, reason = %@", exception.reason);
            }
        }
    }
}

- (void)clearCacheVariables {
    _cacheData = nil;
    _cacheXML = nil;
    _cacheJSON = nil;
    _cacheString = nil;
    _cacheMetadata = nil;
    _dataFromCache = NO;
}

#pragma mark -

- (void)createDirectoryIfNeeded:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        YTKLog(@"create cache directory failed, error = %@", error);
    } else {
        [YTKNetworkUtils addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];

    // Filter cache base path
    NSArray<id<YTKCacheDirPathFilterProtocol>> *filters = [[YTKNetworkConfig sharedConfig] cacheDirPathFilters];
    if (filters.count > 0) {
        for (id<YTKCacheDirPathFilterProtocol> f in filters) {
            path = [f filterCacheDirPath:path withRequest:self];
        }
    }

    [self createDirectoryIfNeeded:path];
    return path;
}

- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl];
    NSString *baseUrl = [YTKNetworkConfig sharedConfig].baseUrl;
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@",
                             (long)[self requestMethod], baseUrl, requestUrl, argument];
    NSString *cacheFileName = [YTKNetworkUtils md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (NSString *)cacheMetadataFilePath {
    NSString *cacheMetadataFileName = [NSString stringWithFormat:@"%@.metadata", [self cacheFileName]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheMetadataFileName];
    return path;
}

@end
