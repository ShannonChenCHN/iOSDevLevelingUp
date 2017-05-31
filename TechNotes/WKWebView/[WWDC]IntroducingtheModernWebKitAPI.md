## Introducing the Modern WebKit API
### WebKit Overview
- Layout Engine behind Safari
- Rendering HTML IMAGE CSS JS
- Start where the Safari interface ends
- Email, iBooks, Messages, your apps

### WebKit in Your App
- UIWebView  UIKit.framework
- WebView WebKit.framework

### What You Will Learn
- Embedding web content in your app
- Taking advantage od new features of the WebKit API
- Customizing how yur app interacts with web content

### The Modern WebKit API
- Same on iOS and OS X
- Modern
- Steamlined 
- Multi-process architecture

- Features
  - Responsive scrolling
  - Fast JavaScript(Nitro JavaScript engine)
  - Built-in gestures
  - Easy app-webpage communication

### Multi-process Architecture
- Web content runs in its own process
  - Consistently responsive
  - Energy efficient
- **At first, every single WKWebView has a isolated Web Content Process provided by WebKit, but when it comes to its limit, the new created WKWebViews would share the same Web Content Process.**

### Adopting the Modern WebKit API

#### Creating a WKWebView

```
WKWebView* webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
```

#### Loading a webpage

```
NSURL *url = [NSURL URLWithString:string];
NSURLRequest *request = [NSURLRequest requestWithURL:url];
[webView loadRequest:request];
```

#### Configurations

```
WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
WKWebView* webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
```
> You could share the same configuration between different WKWebViews if needed.

### WKWebView Actions
`- goBack`
`- goForward`
`- reload`
`- stopLoading`

### WKWebView Properties(KVO Supported)

Name | Type|
----|----|
title | NSString|
URL | NSURL|
loading | BOOL|
estimatedProgress | double|


### Customizing Page Loading
#### Page Loading 
- Action
  - The User Click a Link
  - Using the back/forward button
  - `window.loaction = 'http://www.apple.com/';`
  - Subframe loading (Subframes and frames are documents inside each other)
  - Call `-[WKWebView loadRequest:]`

- Request
- Response
- Data
  
#### WKNavigationDelegate
> You could use `WKNavigationDelegate` methods to decide what to do after received web view's new action and response.

```
- webView:decidePolicyForNavigationAction:decisionHandler:
- webView:decidePolicyForNavigationResponse:decisionHandler:
```

#### WKNavigationAction
#### WKNavigationResponse
  
## Demo: WKPedia
by Beth Dakin(Safari and WebKit Engineer)