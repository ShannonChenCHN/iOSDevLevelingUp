[EGOTableViewPullRefresh](https://github.com/enormego/EGOTableViewPullRefresh)
----


### PullTableView

继承自 UITableView

最关键的5个属性

```
	@property (nonatomic, assign) BOOL pullTableIsRefreshing;   ///< 下拉刷新控件被触发是，该属性会被置为 YES；刷新完毕时你需要手动设置为 NO 来关闭刷新动画；你可以通过设置该属性为 YES 来手动开启下拉刷新
	@property (nonatomic, assign) BOOL pullTableIsLoadingMore;  ///< 规则跟 pullTableIsRefreshing 类似
```
```
	@property (nonatomic, assign) BOOL loadMoreViewEnable;   ///< 是否禁用上拉查看更多控件
	@property (nonatomic, assign) BOOL refreshingViewEnable; ///< 是否禁用下拉刷新控件
```
```
	@property (nonatomic, assign) BOOL lastPage; ///< 是否到了最后一页
```


1.初始化方法 `- initWithFrame: style:` 中，调用了 `-config` 方法，其中初始化了代理拦截器 `MessageInterceptor`，下拉刷新控件`EGORefreshTableHeaderView`，上拉加载更多控件`LoadMoreTableFooterView`。

2.将触摸事件传递给外面的 pullDelegate

3.重写 `-layoutSubviews` 方法，如果禁用了上拉查看更多控件或者下拉刷新控件，就将其移除掉，如果没有禁用上拉查看更多控件，就调整位置。

4.重写 `delegate` 属性的 setter 方法，设置 `MessageInterceptor`。

5.重写 `pullTableIsRefreshing` 属性和 `pullTableIsLoadingMore` 属性的 setter 方法，手动触发下拉刷新和上拉查看更多事件

6.实现 `UISCrollViewDelegate` 的三个方法`-scrollViewDidScroll:`、`-scrollViewDidEndDragging:willDecelerate:`、`-scrollViewWillBeginDragging:`，监听滚动和拖拽事件，并将事件传递给下拉刷新控件和上拉加载更多控件，以及外面的 delegate（也就是 delegateInterceptor.receiver），同时针对上拉查看更多时可能是最后一页做了处理。

7.实现 `EGORefreshTableHeaderDelegate` 和 `LoadMoreTableViewDelegate` 的方法，监听用户触发的下拉刷新事件和上拉查看更多事件，设置 `pullTableIsRefreshing` 和 `pullTableIsLoadingMore` 为 `YES`，并将事件传递给外面的 pullDelegate。


### 延伸阅读：
1.[Intercept Objective-C delegate messages within a subclass](http://stackoverflow.com/questions/3498158/intercept-objective-c-delegate-messages-within-a-subclass)

