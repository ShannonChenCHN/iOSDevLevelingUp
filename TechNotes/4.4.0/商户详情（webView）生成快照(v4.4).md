商户详情生成快照（v4.4）
-------

### 1.需求
将商户详情页的推荐图文内容生成快照分享到朋友圈

### 2.技术实现分析
方案 1：使用 webView 加载快照中要显示的内容，然后对 webView 进行截图。
方案 2：获取图文详情相关数据，根据不同数据绘制 view，再根据 view 生成截图。

在尝试方案 1 时遇到了以下两个问题：
1.高度问题——由于 webView 没有 superView，导致其背后的 scrollView 的 contentSize 计算不出来
解决办法是，将 webView 添加到屏幕上的 view hierarchy 中，并使其不可见，截图后再移除 webView。

2.图片加载问题——只加载了第一屏高度的图片
解决办法是，在第一次 -webViewDidFinishLoad: 成功回调时，reload 一次，但是等待时间会有点长。

关于 webView 截图的实践见 [SCSnapshotManager](https://github.com/ShannonChenCHN/SCSnapshotManager)

方案 1 的优势在于 h5 的灵活度，方案 2 的优势在于可靠性和用户体验，综合考虑，我们决定还是采用方案 2。

### 3.做了哪些工作

### 4.延伸阅读：

1.[Loading hidden/offscreen UIWebView](http://stackoverflow.com/a/21888779/7088321)
2.[我只是想要截个屏](http://blog.startry.com/2016/02/24/Screenshots-With-SwViewCapture/)