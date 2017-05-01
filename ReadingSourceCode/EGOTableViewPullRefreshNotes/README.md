[EGOTableViewPullRefresh](https://github.com/enormego/EGOTableViewPullRefresh)
----


### PullTableView

#### 继承关系

继承自 UITableView，遵守 `EGORefreshTableHeaderDelegate`， `LoadMoreTableFooterDelegate` 协议。

#### 最关键的 5 个公开属性

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
#### PullTableViewDelegate

共 6 个方法
1 个下拉刷新被触发时的回调方法
1 个上拉加载更多被触发时的回调方法

4 个 touch 事件的回调方法

#### 主要逻辑

1.初始化方法 `- initWithFrame: style:` 中，调用了 `-config` 方法，这个方法中初始化了代理拦截器 `MessageInterceptor`，下拉刷新控件`EGORefreshTableHeaderView`，上拉加载更多控件`LoadMoreTableFooterView`，以及一些初始化设置（`pullTableIsRefreshing = NO`, `pullTableIsLoadingMore = NO`, `refreshingViewEnable = YES`, `loadMoreViewEnable = YES`）。[^1]

[^1]:[Intercept Objective-C delegate messages within a subclass](http://stackoverflow.com/questions/3498158/intercept-objective-c-delegate-messages-within-a-subclass)

2.重写 UIResponder 的 touch 事件响应方法，将 touch 事件传递给外面的 `pullDelegate`

3.重写 `-layoutSubviews` 方法，如果禁用了上拉查看更多控件或者下拉刷新控件，就将其移除掉，如果没有禁用上拉查看更多控件，就更新位置。

4.重写 `delegate` 属性的 setter 方法，设置 `MessageInterceptor`。

5.重写 `pullTableIsRefreshing` 属性和 `pullTableIsLoadingMore` 属性的 setter 方法，手动触发下拉刷新和上拉查看更多事件

6.实现 `UISCrollViewDelegate` 的三个方法，监听滚动和拖拽事件，并将事件传递给下拉刷新控件和上拉加载更多控件，以及外面的 delegate（也就是 `delegateInterceptor.receiver`），同时针对上拉查看更多时可能是最后一页做了处理。

`-scrollViewDidScroll:` 方法
传递事件给 `refreshView` 和 `loadMoreView`（如果没被禁用的话），以及 `delegateInterceptor.receiver`

`-scrollViewDidEndDragging:willDecelerate:` 方法
传递事件给 `refreshView` 和 `loadMoreView`（如果没被禁用而且不是最后一页的话），以及 `delegateInterceptor.receiver`

`-scrollViewWillBeginDragging:`方法
传递事件给 `refreshView`，以及 `delegateInterceptor.receiver`，并且根据是否是最后一页来设置 `loadMoreView.footImage`


7.实现 `EGORefreshTableHeaderDelegate` 和 `LoadMoreTableViewDelegate` 的方法，监听用户触发的下拉刷新事件和上拉查看更多事件，设置 `pullTableIsRefreshing` 和 `pullTableIsLoadingMore` 为 `YES`，并将事件传递给外面的 `pullDelegate`。


### EGORefreshTableHeaderView


#### 继承关系

继承自 UIView

#### 最关键的 1 个公开属性和 5 个公开方法

代理属性
```
@property (nonatomic ,weak) id <EGORefreshTableHeaderDelegate> delegate;
```

几个主要的方法
```
/// scrollView 滚动事件的传递
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;- 
/// 结束拖拽手势
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;- 
/// 告知用户开始拖拽
- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView;
/// 结束刷新
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
/// 开始刷新
- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView;
```

#### EGORefreshTableHeaderDelegate


刷新事件回调
``` - (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view; ```

获取最近更新时间的数据源回调
```- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;```


#### 主要逻辑

```isLoading```属性是用来记录当前的刷新状态的，当 ```egoRefreshTableHeaderDidTriggerRefresh``` 方法被调用时是 YES，当 ```egoRefreshScrollViewDataSourceDidFinishedLoading``` 方法被调用时是 NO。

1.```- initWithFrame:``` 方法中初始化并添加子控件（```lastUpdatedLabel```，```statusLabel```，```arrowImage```，```activityView```），并设置一些属性的初始值（```isLoading = NO```, ```[self setState:EGOOPullNormal];```）。

2.```- refreshLastUpdatedDate``` 方法中更新上次刷新时间 label 的显示内容，被 ```- setState:```, ```-egoRefreshScrollViewWillBeginDragging:```调用。

3.```- setState:``` 方法是这个类中最核心的方法，主要是处理一些切换状态时要做的事
	
	- normal -> pulling：更新提示文案，切换箭头方向
	- pulling -> normal：更新提示文案，切换箭头方向，停止 loading 动画
	- normal -> loading：更新提示文案，隐藏箭头，开始 loading 动画

4.`-startAnimatingWithScrollView` 方法
标记 `isLoading` 为 YES，调用 `setState:` 方法切换状态为 `EGOOPullLoading`
这个方法被调用的场景：
	- 自动：用户松手触发 `egoRefreshScrollViewDidEndDragging` 方法中调用该方法
	- 手动：设置了 `PullTableView` 中的 `pullTableIsRefreshing` 属性为 `YES`

5.`-egoRefreshScrollViewDataSourceDidFinishedLoading:` 方法
	> 手动停止刷新时调用，`isLoading` 改为 `NO`，还原 insets，更新状态为 `EGOOPullNormal`
	
6.`scrollView` 事件的一些方法：

- `egoRefreshScrollViewDidEndDragging:`方法
	> 用户下拉松手后，而且不是正在刷新中时，触发下拉刷新事件，回调 `pullDelegate` 的 `egoRefreshTableHeaderDidTriggerRefresh:` 方法，调用 `startAnimatingWithScrollView:` 方法开始刷新。
	
- `- egoRefreshScrollViewDidScroll:`方法
   	> 监听滚动事件，如果是松手后进入刷新状态了（EGOOPullLoading），就让 scrollView 下移一段距离，停滞一段时间；如果是 pulling -> normal，就调用 `setState:` 方法切换状态为 `EGOOPullNormal`，如果是 normal -> pulling，就切换状态为` EGOOPullNormal`。
   	
- `egoRefreshScrollViewWillBeginDragging`方法
	> 刷新更新时间的显示
	
	
### LoadMoreTableFooterView
实现逻辑跟 `EGORefreshTableHeaderView` 基本类似


### 与 MJRefresh 的对比

