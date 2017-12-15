## bug 记录


1. 城市指南轮播崩溃

 https://stackoverflow.com/a/29516989
            
            
```
if(self.collectionView.numberOfSections > resetIndexPath.section &&
    [self.collectionView numberOfItemsInSection:resetIndexPath.section] > resetIndexPath.item) {
    [self.collectionView scrollToItemAtIndexPath:resetIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
```
- 边界条件、错误处理
- 调用 `scrollToItemAtIndexPath:` 前需要添加保护



2. 用模拟器调试时，播放视频和音频都会导致异常断点被触发

https://stackoverflow.com/questions/9683547/avaudioplayer-throws-breakpoint-in-debug-mode


3. 广场频道播放视频时，切换几个 tab 后，发生崩溃：
```
An instance 0x170200c90 of class AVPlayerItem was deallocated while key value observers were still registered with it. Current observation info: <NSKeyValueObservationInfo 0x174c39fe0> ( <NSKeyValueObservance 0x174252d80: Observer: 0x170442580, Key path: status, Options: <New: YES, Old: NO, Prior: NO> Context: 0x0, Property: 0x174252f60> )
CoreFoundation ___exceptionPreproces
```

- 慎用 KVO 
- 为什么 AVPlayerItem、YHVideoView 会比 YHVideoPlayer 先被销毁？
