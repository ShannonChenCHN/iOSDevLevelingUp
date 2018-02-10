#[AFNetworking](https://github.com/AFNetworking/AFNetworking)(v3.1.0) 源码学习



1. README，Quick start
2. Architecture
	- NSURLSession
		- AFURLSessionManager
		- AFHTTPSessionManager
	- Serialization
		- AFURLRequestSerialization
			- AFHTTPRequestSerializer
			- AFJSONRequestSerializer
			- AFPropertyListRequestSerializer
		- AFURLResponseSerialization
			- AFHTTPResponseSerializer
			- AFJSONResponseSerializer
			- AFXMLParserResponseSerializer
			- AFXMLDocumentResponseSerializer (Mac OS X)
			- AFPropertyListResponseSerializer
			- AFImageResponseSerializer
			- AFCompoundResponseSerializer
	- Additional Functionality
	  - Security
	  - Reachability
	  - UIKit

3.方法调用栈

每次发 POST 请求时，都会创建新的 dataTask 和 request 、taskDelegate（跟 task 相关） 

- AFHTTPSessionManager.m
 - POST: parameters: success: failure:
   - POST: parameters: progress: success: failure:
     - dataTaskWithHTTPMethod: URLString: parameters: uploadProgress: downloadProgress: success: failure: （通过 AFHTTPRequestSerializer 创建一个 request，返回一个 dataTask,这个方法中会回调外面传进来的成功、失败 block）
         - dataTaskWithRequest: uploadProgress: downloadProgress: completionHandler:（这个方法中会调用 NSURLSession 的 dataTaskWithRequest: 方法创建一个 dataTask）
             - addDelegateForDataTask: uploadProgress: downloadProgress: completionHandler:（这个方法中创建了一个 AFURLSessionManagerTaskDelegate 对象，所有的回调都赋给 delegate ，）
             - setDelegate: forTask:（根据 taskID 来保存 delegate，铜鼓 delegate 设置进度，同时监听 task 的 resume 和 suspend）


网络回调 block

- URLSession: task: didCompleteWithError:(AFURLSessionManagerTaskDelegate)
  - dataTaskWithHTTPMethod: URLString: parameters: uploadProgress: downloadProgress: success: failure: (AFHTTPSessionManager)
     - 最外层的网络库回调

网络请求回来时移除 delegate 

- URLSession: task: didCompleteWithError: （AFHTTPSessionManager）
   
   
### 问题：
1.AFNetworking 的作用是什么？不用 AFNetworking 直接用系统的不也可以吗？AFNetworking 为什么要对 NSURLConnection/NSURLSession 进行封装？它是如何封装的？
2.AFNetworking 框架的设计思路和原理是什么？
3.AFNetworking 和 MKNetworkKit 以及 ASINetwork 有什么不同?
4. AFNetworking 2.x 和 AFNetworking 3.x 的区别是什么？
   
RLCache](http://nshipster.cn/nsurlcache/)

### 延伸阅读
- [AFNetworking 源码解读系列](https://github.com/Draveness/Analyze/tree/master/contents/AFNetworking)（Draveness） 
- [AFNetworking 源码阅读系列](http://www.cnblogs.com/polobymulberry/category/785705.html)
- [AFNetworking2.0源码解析系列](http://blog.cnbang.net/tech/2320/)（bang's blog）
- [NSHipster: AFNetworking 2.0](http://nshipster.cn/afnetworking-2/)
- [HTTP Content-type 与 AFNetworking](http://www.isaced.com/post-254.html)
- [iOS AFNetWorking源码详解（一）](http://www.jianshu.com/p/b98cf91b9ce2)
- [AFNetworking源码分析](http://www.jianshu.com/p/8eac5b1975de)
- [AFNetworking到底做了什么？](http://www.jianshu.com/p/856f0e26279d)

