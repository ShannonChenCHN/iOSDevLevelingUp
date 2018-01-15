# AutoLayout 和 Masonry

### Tips

#### 1. priority 什么时候使用

	几种不同的 `.priority` 和 `UILayoutPriority` 的对应关系如下：
	 > .priority allows you to specify an exact priority
	 >
	 > - .priorityHigh equivalent to UILayoutPriorityDefaultHigh
	 > - .priorityMedium is half way between high and low
	 > - .priorityLow equivalent to UILayoutPriorityDefaultLow
	
	UILayoutPriority 是什么呢？Apple 官方文档是这样解释的：
	
	> The layout priority is used to indicate to the constraint-based layout system which constraints are more important, allowing the system to make appropriate tradeoffs when satisfying the constraints of the system as a whole.
	
	UIView 有一个 priority 属性，这个属性是干嘛的呢：
	> The priority of the constraint.
	By default, all constraints are required; this property is set to NSLayoutPriorityRequired in macOS or UILayoutPriorityRequired in iOS.
	>
	> If a constraint's priority level is less than NSLayoutPriorityRequired in macOS or UILayoutPriorityRequired in iOS, then it is optional. Higher priority constraints are satisfied before lower priority constraints; however, optional constraint satisfaction is not all or nothing. If a constraint a == b is optional, the constraint-based layout system will attempt to minimize abs(a-b).
	> 
	> Priorities may not change from nonrequired to required, or from required to nonrequired. An exception will be thrown if a priority of NSLayoutPriorityRequired in macOS or UILayoutPriorityRequired in iOS is changed to a lower priority, or if a lower priority is changed to a required priority after the constraints is added to a view. Changing from one optional priority to another optional priority is allowed even after the constraint is installed on a view.
	>
	> Priorities must be greater than 0 and less than or equal to NSLayoutPriorityRequired in macOS or UILayoutPriorityRequired in iOS.
	
	意思就是说，当一个 View 在同一个维度上，有多个约束时，系统在布局时会根据 UIView 上各个约束的优先级来处理，优先满足优先级高的。
	
	
	下面的案例是 Masonry 官方给出的例子，这个 `topInnerView` 在宽度和高度上都同时有三个约束，实际上不论是宽度，还是高度，都是最多只有一个约束能够同时满足，默认的优先级是 `UILayoutPriorityRequired`，所以约束 1（w = 3 * h）和约束2（宽高不超过 topView）的优先级最高，约束 3（宽高跟 superview 相等）优先级为 priorityLow，所以是可选的，优先满足前两个约束。

 ```
	 [self.topInnerView mas_makeConstraints:^(MASConstraintMaker *make) {
	            make.width.equalTo(self.topInnerView.mas_height).multipliedBy(3); // 高度和宽度之间的关系 w = 3 * h
	            
	            make.width.and.height.lessThanOrEqualTo(self.topView);          // 宽高限制
	            make.width.and.height.equalTo(self.topView).with.priorityLow(); // 宽高有一条边跟 superview 相等
	            
	            make.center.equalTo(self.topView);
	        }];
 ```

#### 2. 添加、更新约束

 - mas_make：添加约束
 - mas_remake：移除之前的所有约束，再重新添加

	   ```
	   [self.movingButton remakeConstraints:^(MASConstraintMaker *make) {
	        make.width.equalTo(@(100));
	        make.height.equalTo(@(100));
	        
	        if (self.topLeft) {
	            make.left.equalTo(self.left).with.offset(10);
	            make.top.equalTo(self.top).with.offset(10);
	        }
	        else {
	            make.bottom.equalTo(self.bottom).with.offset(-10);
	            make.right.equalTo(self.right).with.offset(-10);
	        }
	    }];
   ```
 - mas_update：不移除原来的约束，只是更新指定的约束，Apple 官方推荐在 UIView 的 updateConstraints 方法中更新（当然也可以在别的地方调用）
 
	  ```
	    // 添加约束后，可以单独更新该控件的某一个约束
	    [self.button updateConstraints:^(MASConstraintMaker *make) {
	        make.baseline.equalTo(self.mas_centerY).with.offset(self.offset);
	    }];
	  ```

#### 3. 保存约束、更新约束

	- 删除单个约束
	
	```
	// in public/private interface
	@property (nonatomic, strong) MASConstraint *topConstraint;
	
	...
	
	// when making constraints
	[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
	    self.topConstraint = make.top.equalTo(superview.mas_top).with.offset(padding.top);
	    make.left.equalTo(superview.mas_left).with.offset(padding.left);
	}];
	
	...
	// then later you can call
	[self.topConstraint uninstall];
	```
	
	- 更新单个约束
	
	```
	// 添加约束
[_parallaxHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.and.right.equalTo(self.view);
    make.top.equalTo(self.mas_topLayoutGuideBottom);
    // 保存高度约束
    _parallaxHeaderHeightConstraint = make.height.equalTo(@(ParallaxHeaderHeight));
}];
...
_parallaxHeaderHeightConstraint.equalTo(@(ParallaxHeaderHeight - scrollView.contentOffset.y));
	```

#### 4. 动画

	先修改约束，然后再在 UIView 的 animation 方法的 block 中调用 layoutIfNeeded 方法

  ```
int padding = invertedInsets ? 100 : self.padding;
    UIEdgeInsets paddingInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    for (MASConstraint *constraint in self.animatableConstraints) {
        constraint.insets = paddingInsets;
    }

    [UIView animateWithDuration:1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        //repeat!
        [self animateWithInvertedInsets:!invertedInsets];
    }];
  ```

#### 5. 两个相邻 `UILabel` 自适应的问题

 （1）官方 Example Project 推荐方法

  ```

	    [self.longLabel makeConstraints:^(MASConstraintMaker *make) {
	        make.left.equalTo(self.left).insets(kPadding);
	        make.top.equalTo(self.top).insets(kPadding);
	    }];
	
	    [self.shortLabel makeConstraints:^(MASConstraintMaker *make) {
	        make.top.equalTo(self.longLabel.lastBaseline);
	        make.right.equalTo(self.right).insets(kPadding);
	    }];
	
	- (void)layoutSubviews {
	    [super layoutSubviews];
	
	    // for multiline UILabel's you need set the preferredMaxLayoutWidth
	    // you need to do this after [super layoutSubviews] as the frames will have a value from Auto Layout at this point
	
	    // stay tuned for new easier way todo this coming soon to Masonry
	
	    CGFloat width = CGRectGetMinX(self.shortLabel.frame) - kPadding.left;
	    width -= CGRectGetMinX(self.longLabel.frame);
	    self.longLabel.preferredMaxLayoutWidth = width;
	
	    // need to layoutSubviews again as frames need to recalculated with preferredLayoutWidth
	    [super layoutSubviews];
	}
  ```
  
  （2）其他更简单的方法（无需重写 layoutSubviews 方法）
  
  ```
	    [self.longLabel makeConstraints:^(MASConstraintMaker *make) {
	        make.left.equalTo(self.left).insets(kPadding);
	        make.top.equalTo(self.top).insets(kPadding);
	    }];
	
	    [self.shortLabel makeConstraints:^(MASConstraintMaker *make) {
	        make.top.equalTo(self.longLabel.lastBaseline);
	        make.right.equalTo(self.right).insets(kPadding);
	        make.left.equalTo(self.longLabel.mas_right);
	        make.width.mas_greaterThanOrEqualTo(0);
	    }];
  ```
  
#### 6. 一次性设置一组控件的约束（NSArray 有一个分类）

    ```
    // 设置一组控件的某一个约束
    [self.buttonViews makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(self.mas_centerY).with.offset(self.offset);
    }];
   ```



#### 7.  `UIView` 的 `layoutMargins` 属性

   ```
        ...
        view.layoutMargins = UIEdgeInsetsMake(5, 10, 15, 20); // UIView 的 layoutMargins 属性
        [self addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.topMargin);
            make.bottom.equalTo(lastView.bottomMargin);
            make.left.equalTo(lastView.leftMargin);
            make.right.equalTo(lastView.rightMargin);
        }];
```

#### 8. 批量整体添加约束

  ```
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 4; i++) {
        UIView *view = UIView.new;
        view.backgroundColor = [self randomColor];
        view.layer.borderColor = UIColor.blackColor.CGColor;
        view.layer.borderWidth = 2;
        [self addSubview:view];
        [arr addObject:view];
    }
    
    // 批量捆绑添加约束
    [arr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:5 tailSpacing:5];
    [arr makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@60);
        make.height.equalTo(@60);
    }];
  ``` 
  
#### 9. UIViewController 的 layoutGuide

   topLayoutGuide 表示当前页面的上方被 status bar、navigation bar 遮挡的部分。同理，bottomLayoutGuide 表示下方被遮挡的部分。
   有些时候，一个 ViewController 可能单独显示出来，也可能内嵌在 UINavigationController 里面显示出来。在这两种情况下，页面的“可视范围”是不一样的，很明显，NavigationBar 会遮挡住一部分，用了UITabBarController 时，tabBar 也会遮挡住下方一部分。再加上各种 Bar 都可以隐藏，情况会变得更复杂。
所以有了 topLayoutGuide 和 bottomLayoutGuide，我们可以只需要写一份布局代码。

	```
	[topView makeConstraints:^(MASConstraintMaker *make) {
	        make.top.equalTo(self.mas_topLayoutGuide);
	        make.left.equalTo(self.view);
	        make.right.equalTo(self.view);
	        make.height.equalTo(@40);
	    }];
	```
	
#### 10. HuggingPriority 和 CompressionResistancePriority

  - Content Compression Resistance = 不许挤我！
对，这个属性说白了就是“不许挤我”=。=
这个属性的优先级（Priority）越高，越不“容易”被压缩。也就是说，当整体的空间装不下所有的View的时候，Content Compression Resistance优先级越高的，显示的内容越完整。

  - Content Hugging = 抱紧！
这个属性的优先级越高，整个View就要越“抱紧”View里面的内容。也就是View的大小不会随着父级View的扩大而扩大。一般用于 UILabel 之类的控件。

    比如现在有一个 label 和一个 view，两者水平相邻，我们想要让 label 尺寸根据内容变化，左边跟容器保持固定间距，右侧跟 view 保持固定间距，view 的右侧跟容器的右侧保持固定间距。就像下面这样：
    ```
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃  ┏━━━━━━━┓    ┏━━━━━━━┓   ┃
    ┃  ┃ label ┃    ┃ view  ┃   ┃
    ┃  ┗━━━━━━━┛    ┗━━━━━━━┛   ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
    
    
    ```
    
    实现代码如下：
    ```
    // 1. 给 label 添加约束
    // ...
    
    // 2. 设置 label1 的 Hugging Priority，使其宽度跟文字内容一样宽
    [label setContentHuggingPriority:UILayoutPriorityRequired
                                forAxis:UILayoutConstraintAxisHorizontal];
                                
    // 3. 给 view 添加约束
    // ...
    
    ```

#### 11. NSLayoutConstraint 的 constant 属性

  如果约束是一个常量值，可以直接修改 NSLayoutConstraint 的 constant 属性来改变这个值


#### 12. 自动计算 UITableViewCell 高度

	iOS 8 以后：
	
	第一步，给 cell 中的所有子控件添加好约束，如果 UILabel 要支持多行显示时，需要通过手动计算最大宽度，来设置 preferredMaxWidth 属性 
	
	第二步，利用 Self-sizing 机制设置 cell 高度，设置 rowHeight 为 UITableViewAutomaticDimension 或者在 heightForRow 方法中返回 UITableViewAutomaticDimension
	
	```
	// self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 80;
	...
	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	    return UITableViewAutomaticDimension;
	}
```

#### 13. baseline

	在Autolayout里面对应着NSLayoutFormatAlignAllBaseline，也是一种对齐的标准。例如，UIButton的baseline就是内部的文字。
	
	对于自定义的View来说，baseline默认就是整个view的底部，如果想改变baseline的话，可以重写UIView的viewForBaselineLayout，返回当成baseline的view即可。
	
#### 14. MASConstraint 的 -setOffset: 方法

	```
	_leftConstraint.offset = touchPoint.x;
	_topConstraint.offset = touchPoint.y;
	```
	除了 -setOffset: 方法之外，还有 setCenterOffset:、setSizeOffset: 和 setInsets: 方法
	
#### 15. UIView 的 -intrinsicContentSize 方法

   可以通过重写该方法，告知 AutoLayout 系统内容尺寸有多大
   
#### 16. UIView 的 requiresConstraintBasedLayout 方法什么时候用？
   当需要在 -updateConstraints 方法中更新自定义 view 的约束时，但是还没有添加过约束的话，就需要重写该方法。
   
#### 17. 如何实现两个相邻的 view 整体居中？

场景：A 和 B 间距为 10，尺寸根据内容自适应，同时要求在两者共同的 superview C 中保持整体水平居中。

┏━━━━━━━━━━━━━━━━━┓
┃  ┏━━━━┓ ┏━━━┓              ┃
┃  ┃ A           ┃ ┃ B       ┃ C ┃
┃  ┗━━━━┛ ┗━━━┛   ┃
┗━━━━━━━━━━━━━━━━━┛

解决办法：在 superview 中添加一个 subview 作为 container，然后用这个 subview 将 A 和 B 包装起来，先给 container 添加水平居中的约束，并且左边跟 A 的左边对齐，右边跟 B 的右边对齐。

```
[container mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(C);
    make.centerY.equalTo(C);
    make.left.equalTo(A.mas_left);
    make.right.equalTo(B.mas_right);
}];

```
然后再设置 A 和 B 的约束，保证 A 和 B 之间的间距为 10。

```
[A mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(container);
    make.right.equalTo(B.mas_left).offset(-10);
    make.left.greaterThanOrEqualTo(C.mas_left);
}];

[B mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(container);
    make.right.lessThanOrEqualTo(C.mas_right);
}];
```

#### 18. 当只有 title 时，如何设置 UIButton 的 title 内边距，同时保证 button 尺寸根据内容自适应？

有多种方式可以实现，这里用的是最简单的一种方式。
当只有 title 时，设置 `titleEdgeInsets` 不会生效，设置  `contentEdgeInsets` 才会生效。
```
- (IBAction)ChangeTitle:(UIButton *)sender {
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0,20,0,20);
    [self.button setTitle:@"Long Long Title" forState:UIControlStateNormal];
}
```

> 参考：[Autolayout - intrinsic size of UIButton does not include title insets](https://stackoverflow.com/a/37218908)


### 参考：
- [有趣的Autolayout示例-Masonry实现](http://tutuge.me/2015/05/23/autolayout-example-with-masonry/)
- [Masonry 官方文档](https://github.com/SnapKit/Masonry)
- [Autolayout之 关于+requiresConstraintBasedLayout方法作用](http://www.jianshu.com/p/ef6b6578148d)
- [IOS开发通过代码方式使用AutoLayout (NSLayoutConstraint + Masonry)
](http://blog.csdn.net/he_jiabin/article/details/48677911)
- [AutoLayout的那些事儿](http://www.cocoachina.com/ios/20160530/16522.html)
