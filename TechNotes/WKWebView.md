# WKWebView

[ExampleProject](https://github.com/ShannonChenCHN/Playground/tree/master/WebViewDemo)

## 目录
- Complete Guide to Implementing WKWebView
- WKWebView API Reference
- NSHipster: WKWebView
- 相关讨论
- 延伸阅读

### 1.[Complete Guide to Implementing WKWebView](http://samwize.com/2016/06/08/complete-guide-to-implementing-wkwebview/)

- 不能直接在 IB 中直接添加 WKWebView
- 加载网页的两种方式
  - Load HTML as String
  - Load URL request
- App Transport Security policy
- Safari Debugger
  - **Safari > Develper > Simulator/Your Device**
  - For a real device, you will need to enable the feature in **Settings app > Safari > Advanced.**

- 2 delegates
  - `WKUIDelegate`: provides the method for presenting some native user interfaces
  - `WKNavigationDelegate`: track navigations from page to page

- Change a HTTP header value with a `NSMutableURLRequest`

- User-Agent
  - Set User Agent
    - set it on a `NSMutableURLRequest` object's HTTP header value
    - using `webView.customUserAgent` to set just once for the web view
    - change it globally by setting NSUserDefaults
      - [How do I change the WKWebview's user agent in OS X Yosemite?](http://stackoverflow.com/a/27331026/7088321)
      - [Set useragent in WKWebview](http://stackoverflow.com/questions/26994491/set-useragent-in-wkwebview)
  - Get User Agent
    - evelauate JavaScript string `"navigator.userAgent"` in a web view

- Go Back/Forward and Progress

- Print the HTML text

- Pitfall: Handling [Javascript Dialog Boxes](http://www.tutorialspoint.com/javascript/javascript_dialog_boxes.htm)
  - You MUST implement the methods in `WKUIDelegate` to handle Javascript dialog boxes 
  - What’s important are the `UIAlertAction` and the `completionHandler` to call back with

- Pitfall: Unsupported URL
  - Custom scheme URL is not supported by WKWebView (but Safari will work)
  - You can make it work by handling the “error”
  - In iOS 9, you have to [whitelist](https://useyourloaf.com/blog/querying-url-schemes-with-canopenurl/) the URL schemes if you use `canOpenURL`, therefore we simply go ahead and openURL, then use the returned boolean

- Bonus: Universal Links
  - Universal links are `http://...` URL that will open an app. They are similar to custom URI scheme to open app, but using regular http addresses. 


### 2.WKWebView API Reference（Objective-C）

具体使用见[ExampleProject](https://github.com/ShannonChenCHN/Playground/tree/master/WebViewDemo)

#### 2.1 简介：
#### 2.2 初始化：
#### 2.3 加载网页：
#### 2.4 代理方法：
- WKNavigationDelegate
- WKUIDelegate
- WKScriptMessageHandler

### 3.[NSHipster: WKWebView](http://nshipster.cn/wkwebkit/)

#### 3.1 简介
- iOS 与 web 之间的关系
- Web 一直是 iOS 系统上的二级公民
- UIWebView 笨重难用，还有内存泄漏，和 Nirtro JavaScript 引擎谈笑风生的 Safari 不知道要比它高到哪里去了。
- 改变现状：WKWebView 和 WebKit 框架其他部分的出现

- WKWebView 的优点
  - 拥有 60fps 滚动刷新率
  - 内置手势识别
  - 高效的 app-web 间信息交流
  - 和 Safari 相同的 JavaScript 引擎

- API 的变化：
  - UIWebView 和 UIWebViewDelegate 在 WKWebKit 中被重构成 14 个类和 3 个协议


#### 3.2 WKWebKit Framework
**Classes**
- `WKWebView`: Displays embeded interactive web content
- `WKBackForwardList`: The web view's back-forward list.
  - `WKBackForwardListItem`: Represents a webpage in the back-forward list of a web view.
- `WKWebViewConfiguration`: A collection of properties with which to initialize a web view.
    - `WKUserContentController`: Provides a way for JavaScript to post messages and inject user scripts to a web view.
    - `WKScriptMessage`: Contains information about a message sent from a webpage.
    - `WKUserScript`: Represents a script that can be injected into a webpage.
  - `WKPreferences`: Encapsulates the preference settings for a web view.
  - `WKProcessPool`: Represents a pool of Web Content processes.
- `WKWebsiteDataStore`: Represents various types of data used by a chosen website. 
  - `WKWebsiteDataRecord`: Represents website data grouped by the originating URL’s domain name and suffix.
- `WKNavigation`: Contains information for tracking the loading progress of a webpage.
  - `WKNavigationAction`: Contains information about an action that may cause a navigation, used for making policy decisions.
  - `WKNavigationResponse`: Contains information about a navigation response, used for making policy decisions.
- `WKWindowFeatures`: Specifies optional attributes for the containing window when a new web view is requested.
- `WKFrameInfo`: Contains information about a frame on a webpage.

**Protocols**
- `WKNavigationDelegate`: Provides methods for tracking progress for main frame navigations and for deciding
policy for main frame and subframe navigations.
- `WKUIDelegate`: Provides methods for presenting native UI on behalf of a webpage.
- `WKScriptMessageHandler`: Provides a method for receiving messages from JavaScript running in a webpage.

#### 3.3 API Diff Between UIWebView & WKWebView


#### 3.4 JavaScript ↔︎ Swift Communication

- Injecting Behavior with User Scripts
  - WKUserScript allows JavaScript behavior to be injected at the start or end of document load.
  - This powerful feature allows for web content to be manipulated in a safe and consistent way across page requests.
  - Example 
    - changing the background color of a web page.
    - removing advertisements
    - hiding comments

- Message Handlers
  - information from a web page can be passed back to the app by invoking:

  ```
  window.webkit.messageHandlers.{NAME}.postMessage({MESSAGE})
  ```

  - The name of the handler is configured in `addScriptMessageHandler()`, which registers a handler conforming to the WKScriptMessageHandler protocol.
  - The same approach can be used to scrape information from the page for display or analysis within the app. See [example](http://nshipster.com/wkwebkit/).

### 4.讨论：

- 为什么我们要替换 UIWebView
  - WKWebView 解决了 UIWebView 的哪些痛点
  - WKWebView 相比 UIWebView 在性能上的提升
- WKWebView 目前存在的一些缺陷


### 5.延伸阅读：

- [WebKit Objective-C Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DisplayWebContent/DisplayWebContent.html#//apple_ref/doc/uid/10000164-SW1)
- [Using JavaScript with WKWebView in iOS 8](http://www.joshuakehn.com/2014/10/29/using-javascript-with-wkwebview-in-ios-8.html)
- [mozilla-mobile/firefox-ios](https://github.com/mozilla-mobile/firefox-ios) 
- [WebKit-Wikipedia](https://zh.wikipedia.org/wiki/WebKit)


