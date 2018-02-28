[Mantle](https://github.com/Mantle/Mantle)(v 2.1.0)
-------

### 主要逻辑

```
+ [MTLJSONAdapter modelOfClass:fromJSONDictionary:error:]
	- [MTLJSONAdapter initWithModelClass:]              // 初始化 MTLJSONAdapter
	- [MTLJSONAdapter modelFromJSONDictionary:error:]   // 返回 model 结果
```


### 延伸阅读
- [《iOS进阶指南》试读之《Mantle解析》](http://www.jianshu.com/p/f49ddbf8a2ea)
- [iOS模型框架- Mantle 解读](http://www.jianshu.com/p/d9e66beedb8f)
- YYModel 相关
   - [YYModel源代码分析（一）整体介绍](http://www.jianshu.com/p/5428552be6ce)
   - [YYModel源代码分析（二）YYClassInfo](http://www.jianshu.com/p/012dbce17a50)
   - [YYModel源代码分析（三）NSObject+YYModel](http://www.jianshu.com/p/7cf8b43f5d88)
   - [一篇文章全吃透—史上最全YYModel的使用详解](http://www.jianshu.com/p/25e678fa43d3)
   - [手把手带你撸一个 YYModel 的精简版](http://www.jianshu.com/p/b822285f73ac)
   - [揭秘 YYModel 的魔法](https://lision.me/yymodel_x01/)
