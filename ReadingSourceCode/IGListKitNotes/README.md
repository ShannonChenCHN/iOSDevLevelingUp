# IGListKit


### 亮点
- 更好的架构：
  - 封装了 UICollectionView 的代理方法
  - 通过将 UIViewController  中的逻辑分散到 UIViewController， List adapter，section controller 和 cell 中，以减低 massive view controllers 出现的可能性
  - 可复用的 section controller 和 cell
- Working range
- Diff 算法
  - 更方便地增删改移，不用再繁琐地手动调用 performBatchUpdates 方法，也不用担心 crash 的问题了


### 参考
- [Open Sourcing IGListKit](https://engineering.instagram.com/open-sourcing-iglistkit-3d66f1e4e9aa)
- [Instagram/IGListKit实践谈](http://www.jianshu.com/p/44bda1421757)
- [IGListKit diff 实现简析](http://xiangwangfeng.com/2017/03/16/IGListKit-diff-%E5%AE%9E%E7%8E%B0%E7%AE%80%E6%9E%90/)
