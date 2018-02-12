//
//  ExampleTableViewController.m
//  AFNetworking Example
//
//  Created by ShannonChen on 2017/5/8.
//
//

#import "ExampleTableViewController.h"
@import AFNetworking;

static NSString * const kTableSectionTitleKey = @"kTableSectionTitleKey";
static NSString * const kTableSectionContentsKey = @"kTableSectionContentsKey";
static NSString * const kTableCellTitleKey = @"kTableCellTitleKey";
static NSString * const kTableCellSelectionSelectorKey = @"kTableCellSelectionSelectorKey";

@interface ExampleTableViewController ()

@property (strong, nonatomic) NSArray <NSDictionary *> *items;

@end

@implementation ExampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Examples", nil);
    
    self.items = @[@{kTableSectionTitleKey : @"NSURLSession",
                     kTableSectionContentsKey : @[@{kTableCellTitleKey : @"Create An NSURLSessionTask",
                                                    kTableCellSelectionSelectorKey : NSStringFromSelector(@selector(createAnNSURLSessionTask))}]
                     },
                   @{kTableSectionTitleKey : @"AFNetworking",
                     kTableSectionContentsKey : @[@{kTableCellTitleKey : @"Creates an `NSURLSessionDownloadTask` with the specified request",
                                                    kTableCellSelectionSelectorKey : NSStringFromSelector(@selector(createADownloadTask))},
                                                    @{kTableCellTitleKey : @"Creates an `NSURLSessionUploadTask` with the specified request for a local file",
                                                      kTableCellSelectionSelectorKey: NSStringFromSelector(@selector(createAnUploadTask))},
                                                  @{kTableCellTitleKey : @"Creates an `NSURLSessionUploadTask` with the specified streaming request.",
                                                  kTableCellSelectionSelectorKey : NSStringFromSelector(@selector(createAnUploadTaskForMultiPartRequest))},
                                                  @{kTableCellTitleKey : @"Create an `NSURLSessionDataTask` with AFHTTPRequestSerializer",
                                                    kTableCellSelectionSelectorKey : NSStringFromSelector(@selector(createADataTask))},
                                                  @{kTableCellTitleKey : @"Creates and runs an `NSURLSessionDataTask` with a `GET` request",
                                                    kTableCellSelectionSelectorKey : NSStringFromSelector(@selector(createAGetRequestThroughAFHTTPSessionManager))}]
                     }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.items.count) {
        NSArray *cellTitles = self.items[section][kTableSectionContentsKey];
        
        return cellTitles.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSArray *cellTitles = self.items[indexPath.section][kTableSectionContentsKey];
    cell.textLabel.text = cellTitles[indexPath.row][kTableCellTitleKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *cellTitles = self.items[indexPath.section][kTableSectionContentsKey];
    NSString *selectorString = cellTitles[indexPath.row][kTableCellSelectionSelectorKey];
    
    if (selectorString) {
        [self performSelector:NSSelectorFromString(selectorString)];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString * const headerIdentifier = @"headerIdentifier";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
    }
    
    header.textLabel.text = self.items[section][kTableSectionTitleKey];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - Network

- (void)createAnNSURLSessionTask {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://github.com"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseString);
    }];
    [task resume];
}

- (void)createADownloadTask {
    // Create a AFURLSessionManager based on a specified NSURLSessionConfiguration.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a URL request based on a specified NSURL object.
    NSURL *URL = [NSURL URLWithString:@"https://camo.githubusercontent.com/1560be050811ab73457e90aee62cd1cd257c7fb9/68747470733a2f2f7261772e6769746875622e636f6d2f41464e6574776f726b696e672f41464e6574776f726b696e672f6173736574732f61666e6574776f726b696e672d6c6f676f2e706e67"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    // Create a NSURLSessionDownloadTask.
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *URL = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
        return URL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    
    // Resumes the download task.
    [downloadTask resume];
}

- (void)createAnUploadTask {
    // Create a AFURLSessionManager based on a specified NSURLSessionConfiguration.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a URL request based on a specified NSURL object.
    NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    // Create a NSURL object for the file need to be uploaded.
    NSURL *filePath = [NSURL fileURLWithPath:@"file://"];
    
    // Create a NSURLSessionUploadTask.
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error： %@", error);
        } else {
            NSLog(@"Success: %@, %@", response, responseObject);
        }
    }];
    
    // Resumes the upload task.
    [uploadTask resume];
}

- (void)createAnUploadTaskForMultiPartRequest {
    
    // Create a multi-part form request
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:@"http://example.com/upload" parameters:nil
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"]
                                                                                                             name:@"file"
                                                                                                         fileName:@"filename.jpg"
                                                                                                         mimeType:@"image/jpeg"
                                                                                                            error:nil];
                                                                              } error:nil];
    
    // Create a AFURLSessionManager based on a specified NSURLSessionConfiguration.
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // Create a NSURLSessionUploadTask.
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:^(NSProgress * _Nonnull uploadProgress) {
                                                   
                                                   // This is not called back on the main queue.
                                                   // You are responsible for dispatching to the main queue for UI updates
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       //Update the progress view
                                                       //                          [progressView setProgress:uploadProgress.fractionCompleted];
                                                   });
                                               }
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          if (error) {
                                              NSLog(@"Error: %@", error);
                                          } else {
                                              NSLog(@"%@ %@", response, responseObject);
                                          }
                                      }];
    
    // Resumes the upload task.
    [uploadTask resume];
}


- (void)createADataTask {
    // Create a AFURLSessionManager based on a specified NSURLSessionConfiguration.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a URL request based on a specified NSURL object.
    //*** Request Serialization ***//
    // Request serializers create requests from URL strings, encoding parameters as either a query string or HTTP body.
    NSString *URLString = @"http://example.com";
    NSDictionary *parameters = @{@"foo": @"bar",
                                 @"baz": @[@1,
                                           @2,
                                           @3]
                                 };
    NSURLRequest *request = nil;
    
    // 1. Query String Parameter Encoding
    /**
     GET http://example.com?foo=bar&baz[]=1&baz[]=2&baz[]=3
     */
//    request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil];
    
    
    // 2. URL Form Parameter Encoding
    /**
     POST http://example.com/
     Content-Type: application/x-www-form-urlencoded
     
     foo=bar&baz[]=1&baz[]=2&baz[]=3
     */
    AFHTTPRequestSerializer *HTTPSerializer = [AFHTTPRequestSerializer serializer];
    HTTPSerializer.HTTPShouldHandleCookies = YES;
    request = [HTTPSerializer requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
    
    
    // 3. JSON Parameter Encoding
    /**
     POST http://example.com/
     Content-Type: application/json
     
     {"foo": "bar", "baz": [1,2,3]}
     */
//    request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
    
    
    
    // Create a data task
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    
    // Resumes the data task.
    [dataTask resume];
}


- (void)createAGetRequestThroughAFHTTPSessionManager {
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    // response 解析设置
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    manager.responseSerializer = responseSerializer;
    
    [manager GET:@"" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", htmlString);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


@end
