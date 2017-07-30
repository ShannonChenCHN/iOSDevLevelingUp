### WebViewJavascriptBridge 框架详解

### 目录
- 一、简介
- 二、实现原理
- 1. 流程图
- 2. 目录结构
- 3. 主要逻辑
- 三、实现细节
- 四、知识点
- 五、收获与疑问
- 六、延伸阅读

### 一、简介
#### 1. 设计目的
我们平时使用 `UIWebView` 时，原生和 JavaScript 的交互一般是通过以下两种方式实现的：
- Native to JavaScript：原生通过 `-stringByEvaluatingJavaScriptFromString:` 方法执行一段 JavaScript
- JavaScript to Native：在网页中加载一个 Custom URL Scheme 的链接（直接设置 window.location 或者新建一个 iframe 去加载这个 URL），原生中拦截 `UIWebView` 的代理方法 `- webView:shouldStartLoadWithRequest:navigationType: `，然后根据约定好的协议做相应的处理
这两种方式的弊端在于 h5 
用来解决 `WKWebView`、`UIWebView`（iOS） 以及 `WebView`（OSX）中， Objective-C 和 JavaScript 之间互相发送消息的一种机制。

#### 2. 特性
- Objective-C 中发送消息给 web view 中的 JavaScript
- web view 中的 JavaScript 发送消息给 Objective-C
- 不论是原生还是 JavaScript，发送消息的过程就像平时调用方法一样简单
- 发送消息时不仅可以带参数，还可以传 callback

#### 3. 安装

3.1 使用 pod 安装
直接在 podfile 中加入下面这行代码，并执行 `pod install` 命令：
``` Ruby
pod 'WebViewJavascriptBridge', '~> 6.0'
```

3.2 手动导入
在 WebViewJavascriptBridge 的 [GitHub repository](https://github.com/marcuswestin/WebViewJavascriptBridge) 上下载源码后，从下载好的文件中将 `WebViewJavascriptBridge` 文件夹直接拖入你的工程中。

#### 4. API

#### 4.1 Objective-C API

``` Objective-C
// 为指定的 web view （WKWebView/UIWebView/WebView）创建一个 JavaScript Bridge 
+ (instancetype)bridgeForWebView:(id)webView;
```

``` Objective-C
// 注册一个名称为 handlerName 的 handler 给 JavaScript 调用
// 当在 JavaScript  中调用 WebViewJavascriptBridge.callHandler("handlerName")  时，该方法的 WVJBHandler 参数会收到回调
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
```

``` Objective-C
// 调用 JavaScript 中注册过的 handler
// data 参数为调用 handler 时要传递给 JavaScript 的参数，responseCallback 传给 JavaScript 用来回调
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
```

``` Objective-C
// 如果你需要监听 web view 的代理方法的回调，可以通过该方法设置你的 delegate
- (void)setWebViewDelegate:(id)webViewDelegate;
```

#### 4.2 JavaScript API
``` JavaScript
// 注册一个  handler 给 Objective-C 调用
registerHandler(handlerName: String, handler: function);
```

``` JavaScript
// 调用 Objective-C 中注册过的 handler
callHandler(handlerName: String);
callHandler(handlerName: String, data: undefined);
callHandler(handlerName: String, data: undefined, responseCallback: function);
```

#### 5. 基本用法

5.1 导入头文件，声明一个 `WebViewJavascriptBridge` 属性：
``` Objective-C
#import "WebViewJavascriptBridge.h"
```
...
``` Objective-C
@property WebViewJavascriptBridge* bridge;
```

5.2 为你的 `WKWebView`、`UIWebView` (iOS)或者`WebView` (OSX) 创建一个 `WebViewJavascriptBridge ` 对象：
``` Objective-C
self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
```

5.3 在 Objective-C 中注册 handler 和调用 JavaScript 中的 handler：
``` Objective-C
[self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
NSLog(@"ObjC Echo called with: %@", data);
responseCallback(data);
}];
[self.bridge callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
NSLog(@"ObjC received response: %@", responseData);
}];
```

5.4 复制下面的 `setupWebViewJavascriptBridge` 函数到你的 JavaScript 代码中：
``` JavaScript
function setupWebViewJavascriptBridge(callback) {
if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
window.WVJBCallbacks = [callback];
var WVJBIframe = document.createElement('iframe');
WVJBIframe.style.display = 'none';
WVJBIframe.src = 'https://__bridge_loaded__';
document.documentElement.appendChild(WVJBIframe);
setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}
```

5.5 调用 `setupWebViewJavascriptBridge` 函数，使用 `bridge` 来注册 handler 和调用 Objective-C 中的 handler：
``` Javascript
setupWebViewJavascriptBridge(function(bridge) {

/* Initialize your app here */

bridge.registerHandler('JS Echo', function(data, responseCallback) {
console.log("JS Echo called with:", data)
responseCallback(data)
})
bridge.callHandler('ObjC Echo', {'key':'value'}, function responseCallback(responseData) {
console.log("JS received response:", responseData)
})
})
```

#### 6. 其他玩法

### 二、实现原理
#### 1. 流程图
#### 2. 目录结构
#### 3. 主要逻辑


### 三、实现细节
[带有详细注释的源码](https://github.com/ShannonChenCHN/iOSLevelingUp/tree/master/ReadingSourceCode/WebViewJavascriptBridgeNotes/WebViewJavascriptBridge-6.0.2)

### 四、知识点

### 五、收获与疑问

### 六、延伸阅读
- [WebViewJavascriptBridge原理解析](http://www.jianshu.com/p/d45ce14278c7)
- [WebViewJavascriptBridge机制解析](http://www.jianshu.com/p/8bd6aeb719ff)
