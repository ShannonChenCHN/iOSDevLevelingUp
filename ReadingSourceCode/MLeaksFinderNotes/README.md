# MLeaksFinder

### 核心思路：
当一个 ViewController 被 pop 或 dismiss 之后，我们认为该 ViewController，包括它上面的子 ViewController，以及它的 View，View 的 subView 等等，都很快会被释放，如果某个 View 或者 ViewController 没释放，我们就认为该对象泄漏了。

### 实现步骤：
1. 通过 Method Swizzling 重写 `UINavigationController` 的 `popViewControllerAnimated:` 方法：取出要 pop 出栈的 controller，标记该 controller 的 kHasBeenPoppedKey “属性”为 YES；
2. 当一个 controller 被 pop 出栈时， `UINavigationController` 的 `popViewControllerAnimated:` 方法就被调用，接着该 controller 的  `viewDidDisappear` 方法被调用，然后就会调用 `willDealloc` 方法，递归调用  `childViewController` 和 `presentedViewController`，以及 `subviews` 的  `willDealloc` 方法；



https://github.com/Tencent/MLeaksFinder
http://wereadteam.github.io/2016/02/22/MLeaksFinder/
http://wereadteam.github.io/2016/07/20/MLeaksFinder2/
