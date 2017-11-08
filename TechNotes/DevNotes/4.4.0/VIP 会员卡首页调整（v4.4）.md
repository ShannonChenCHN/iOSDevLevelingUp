VIP 会员卡首页调整（v4.4）
-------

### 1.需求
- 由 UIWebView 改为 WKWebView
- 由二级页面改为一级页面

### 2.实现

#### 2.1 由 UIWebView 改为 WKWebView
几个问题
- cookie 共享
- h5 与原生的交互
   - 目前我们的 webView 采用了哪些方式来处理交互/跳转？都是通过拦截 webView:shouldStartLoadWithRequest:方法？
   - h5 是通过哪些方式来处理响应事件的？onclick？设置 window.loaction？
- UserAgent
- WKWebView 和 UIWebView 的异同
- 应急方案
- 兼容 iOS7

几个步骤：
1.WKWebView 的用法和坑点
2.WKWebView 在项目中的实践
   - cookie 共享
   - 现有的 cookie 管理机制
   - h5 与原生的交互
3.项目中 YHBaseWebView 的所需要支持的功能、逻辑
4.如何在 YHWKWebView 中实现 YHBaseWebView 的功能、逻辑
5.同时兼容 UIWebView 和 WKWebView 的封装


#### 2.2 由二级页面改为一级页面
- 导航栏，标题是否需要写死？
- scheme 跳转
- webView 预加载
- 容错
- 同时兼容二级页面（首页轮播图配置）
  - 导航栏
  - webview 的 contentInset
  - errorView 的层级
- 为防止网络不佳的情况下页面加载异常， webView 是否又刷新入口？
   - 重复点击底部 tabBar 按钮，刷新页面




1. tableView 快速滑动
2. tableView 中两个相同 url 是否重复下载