# WKWebView 相关开源项目的实现


### [dfmuir/KINWebBrowser](https://github.com/dfmuir/KINWebBrowser) 的实现

- 代码非常干净、规范😮
- 基于 UIWebView 和 WKWebView
- 以 Controller 作为容器
- 带有 progressBar 和标题
- 底部有 toolBar，可前进后退、刷新
- 针对 External APP URL 做了处理

### [devedbox/AXWebViewController](https://github.com/devedbox/AXWebViewController) 的实现

### [li6185377/IMYWebView](https://github.com/li6185377/IMYWebView) 的实现

### 造轮子

- 封装成 UIView 还是 UIViewController
- 支持哪些功能




### 延伸阅读

#### 开源项目
- web browser
  - [dfmuir/KINWebBrowser](https://github.com/dfmuir/KINWebBrowser) ：同时支持 UIWebView 和 WKWebView 的内嵌浏览器。
  - [dzenbot/DZNWebViewController](https://github.com/dzenbot/DZNWebViewController): A simple web browser for iPhone & iPad with similar features than Safari's
- [TimOliver/TOWebViewController](https://github.com/TimOliver/TOWebViewController): A view controller class for iOS that allows users to view web pages directly within an app.
  - [devedbox/AXWebViewController](https://github.com/devedbox/AXWebViewController): 基于UIWebView（iOS 8.0 以上使用 WKWebView 实现）封装的网页浏览控制器。
  - [Roxasora/RxWebViewController](https://github.com/Roxasora/RxWebViewController)：实现类似微信的 webView 导航效果，包括进度条，左滑返回上个网页或者直接关闭，就像 UINavigationController。
  - [coffellas-cto/GDWebViewController](https://github.com/coffellas-cto/GDWebViewController)(Swift): WKWebview browser view controller in Swift.
  - [dzenbot/DZNWebViewController](https://github.com/dzenbot/DZNWebViewController): An iPhone/iPad web browser built on top of WebKit with navigation controls and contextual features, useful for in-app web browsing. Designed to be subclassed and extended.
  - [mtigas/OnionBrowser](https://github.com/mtigas/OnionBrowser): An open-source, privacy-enhancing web browser for iOS, utilizing the Tor anonymity network.
  - [mozilla-mobile/firefox-ios](https://github.com/mozilla-mobile/firefox-ios): Firefox for iOS.
  - [haifengkao/YWebView](https://github.com/haifengkao/YWebView): WKWebview with persistent cookies support.
  - [li6185377/IMYWebView](https://github.com/li6185377/IMYWebView): UIWebView seamless switching to WKWebView.
  - [douban/rexxar-ios](https://github.com/douban/rexxar-ios): Mobile Hybrid Framework Rexxar iOS Container.
  - [XWebView/XWebView](https://github.com/XWebView/XWebView)(Swift): An extensible WebView for iOS (based on WKWebView).
  - [jessesquires/JSQWebViewController](https://github.com/jessesquires/JSQWebViewController)(Swift): A lightweight Swift WebKit view controller for iOS.

- 相关控件
  - [ninjinkun/NJKWebViewProgress](https://github.com/ninjinkun/NJKWebViewProgress): UIWebView progress interface

- JS<->Native 
  - [marcuswestin/WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge): An iOS/OSX bridge for sending messages between Obj-C and JavaScript in UIWebViews/WebViews 
  - [casatwy/CTJSBridge](https://github.com/casatwy/CTJSBridge): a javascript bridge for iOS app to interact with h5 web view.
- 调试工具
  - [Naituw/WBWebViewConsole](https://github.com/Naituw/WBWebViewConsole)：一个 APP 内调试工具，同时支持 WKWebView 和 UIWebView。
  - [marcuswestin/WebViewProxy](https://github.com/marcuswestin/WebViewProxy): A standalone iOS & OSX class for intercepting and proxying HTTP requests (e.g. from a Web View)
