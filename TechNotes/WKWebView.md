# WKWebView


### Complete Guide to Implementing WKWebView

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


### WKWebView API Reference（Objective-C）

简介：
初始化：
加载网页：
代理方法：






