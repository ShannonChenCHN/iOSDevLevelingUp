# Protocol Buffer

## 简介

相对于传统的 XML 和 JSON, Protocol buffers 的优势主要在于：更加小、更加快。对于自定义的数据结构，Protobuf 可以通过生成器生成不同语言的源代码文件，读写操作都非常方便。



## 在 iOS 中使用 PB
1. 安装 Protocol Buffer，到 GiHub repo 上下载源码，按文档安装即可。

2.  创建 .proto 文件，再用 Protobuf 编译器生成目标语言（这里是 Objective-C）所需要的源代码文件，也就是一个定义了 model 类的文件。

3. 在项目中导入 PB 编解码相关的代码，有三种导入方式

- 手动导入源文件
- 手动导入静态库
- 使用 CocoaPods 管理


## 原理
### Protocol Buffer

Protocol Buffer 的主要优点在于小巧、快速：
- 序列化后的信息的表示非常紧凑，信息量小
- 解析速度快

这两个优点主要源于两点：
- 巧妙的 Encoding 技术
  - Varint 表示法
  - Zigzag 编码
- 简单的反序列化过程
  - 不需要复杂的词法语法分析
  - 消息的 decoding 过程通过几个位移操作组成的表达式计算即可完成
  
  
Protocol Buffer 的缺点：

- 由于序列化后的 PB 数据是二进制数据，不能直接阅读

### Objective-C 中的 decode 逻辑


- GPBMessage：所有的 model 都需要继承自 GPBMessage，
- Descriptor（PB 编译器会自动为每个 GPBMessage 子类实现 descriptor 方法，创建 Descriptor）
  - GPBFileDescriptor：用于描述一个 proto 文件
  - GPBDescriptor：一个 GPBDescriptor 表征一个 proto message，对应一个 OC 类.
  - GPBFieldDescriptor：用于描述每个 proto field，对应一个 OC 属性
- GPBCodedInputStream：包装二进制数据的 input stream，包括 state 和 buffer 两部分


在 Protocol Buffer 的 Objective-C 解码库中，解析 PB 数据的逻辑可以简单理解为：

通过在 GPBMessage 子类中实现的  Descriptor（包括 GPBFileDescriptor、 GPBDescriptor 和 GPBFieldDescriptor），指定 Message 以及各属性的一些信息，然后再循环遍历这个 GPBMessage 子类的各个属性对应的 Descriptor，对属性进行赋值。


### Protocol Buffer 源码

protobuf 是跨平台的，protobuf 大概分成两部分：
- compiler：主要是根据 PB message 数据生成对应的目标语言代码。
- runtime：主要功能是在运行时对消息的序列化和反序列化。

## 参考
- [Google Protocol Buffer 的使用和原理](https://www.ibm.com/developerworks/cn/linux/l-cn-gpb/)
- [ Google's Protocol Buffer](https://developers.google.com/protocol-buffers/)
- [google/protobuf](https://github.com/google/protobuf)
- [apple/swift-protobuf](https://github.com/apple/swift-protobuf)
- [高效的数据压缩编码方式 Protobuf](https://github.com/halfrost/Halfrost-Field/blob/master/contents/Protocol/Protocol-buffers-encode.md)
- [还在用JSON? Google Protocol Buffers 更快更小 (原理篇) - 随手记技术团队](https://mp.weixin.qq.com/s?__biz=MzUyNzMwMTAwNw==&mid=2247483736&idx=1&sn=247c204880bde06eda8b77fd14e4d93a&chksm=fa00e1b8cd7768aee094020746eda244b26f2bb78332e8c68257f80d7966ed1ba82ed23dfe23&scene=21#wechat_redirect)
- [还在用JSON? Google Protocol Buffers 更快更小(iOS 实践篇) - 随手记技术团队](https://mp.weixin.qq.com/s/y0dyK47_sirCteAkbh_ebw)
- [Introduction to Protocol Buffers on iOS](https://www.raywenderlich.com/149335/introduction-protocol-buffers-ios)
- [JSON vs Protocol Buffers vs FlatBuffers](https://codeburst.io/json-vs-protocol-buffers-vs-flatbuffers-a4247f8bda6f)
- [5 Reasons to Use Protocol Buffers Instead of JSON For Your Next Service](https://codeclimate.com/blog/choose-protocol-buffers/)
- [Protocol Buffers - WikiPedia](https://en.wikipedia.org/wiki/Protocol_Buffers)
- [如何阅读protobuf源码？ - 陈硕的回答 - 知乎](https://www.zhihu.com/question/66985015/answer/248570196)

