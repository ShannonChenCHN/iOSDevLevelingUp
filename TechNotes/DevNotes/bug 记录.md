## bug 记录


1.城市指南轮播崩溃

 https://stackoverflow.com/a/29516989
            
            
```
if(self.collectionView.numberOfSections > resetIndexPath.section &&
    [self.collectionView numberOfItemsInSection:resetIndexPath.section] > resetIndexPath.item) {
    [self.collectionView scrollToItemAtIndexPath:resetIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
```

- 当列表中数据为空时，调用 `scrollToItemAtIndexPath:` 会导致 `invalid index path` 的错误

- 措施：
 - 调用 `scrollToItemAtIndexPath:` 前需要添加保护
 - 边界条件、错误处理


2.用模拟器调试时，播放视频和音频都会导致异常断点被触发

https://stackoverflow.com/questions/9683547/avaudioplayer-throws-breakpoint-in-debug-mode

- 原因：在 debug 模式下，使用 AVPLayer 播放食品和音频时都会出现这种情况，貌似是系统内部的 C++ 代码异常
- 措施：设置异常断点只对 Objective-C 错误有效


3.广场频道播放视频时，切换几个 tab 后，发生崩溃：
```
An instance 0x170200c90 of class AVPlayerItem was deallocated while key value observers were still registered with it. Current observation info: <NSKeyValueObservationInfo 0x174c39fe0> ( <NSKeyValueObservance 0x174252d80: Observer: 0x170442580, Key path: status, Options: <New: YES, Old: NO, Prior: NO> Context: 0x0, Property: 0x174252f60> )
CoreFoundation ___exceptionPreproces
```

- 问题：为什么 AVPlayerItem、YHVideoView 会比 YHVideoPlayer 先被销毁？
- 措施：
  - 通过 strong 持有 playerItem，防止 playerItem 比作为 observer 的 self 更早销毁造成崩溃 
  - 慎用 KVO ，使用时要确保 register 和 remove 事件一致
  

4.首次安装时，选择城市页面后就出现闪退

- 原因：向字典中插入 nil 导致崩溃
- 措施：


5.iOS 8 系统上附近商圈底部的轮播推荐不能完全展示

- 原因：iOS 8 系统上 UICollectionView 的 cell 复用问题，
- 措施：
  - 代码逻辑不够严谨，没有提前列清楚
  - 开发时需要在不同系统上进行测试

