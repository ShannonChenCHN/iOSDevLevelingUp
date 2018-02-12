# 崩溃问题



### 1.崩溃现象：

- 闪退
- 连续闪退，无法正常打开应用，需要重装应用
- 使用过程中的崩溃

### 2.常见崩溃原因：

- 数组越界
- 内存溢出
- 内存管理（访问已经释放掉的对象）
- CPU 暴增
- 未知选择器
- API 不兼容，比如在 iOS 8 的系统上使用了 iOS 9 的 API
- 处理字符串时索引越界
- 传空值，比如往 NSDictionary 或者 NSArray 中插入 nil
- 解析服务端返回的 JSON 数据后，出现 NSNull，间接引起的崩溃
- block 回调时没有判空
- [How Not to Crash](http://inessential.com/hownottocrash)

### 3.分析崩溃

- 查看后台崩溃日志
- 查看真机日志
- bug 追踪信息：
   - 基本信息
     - 设备/机型
     - 系统版本
     - 网络环境
     - APP 版本号
     - 预期结果与实际结果的对比
     - bug 出现场景（症状）、时间， 能否复现，复现步骤，是必现还是偶现？
     - 是否有其他人遇到过类似问题
   - 其他补充信息
     - bug 出现前打开 APP 后使用时长
     - 是否越狱
     - 用户是否登录、用户信息

### 4.解决步骤
- 查看 stack trace
- 尝试复现


### 5.如何减少崩溃 bug

- 自测/测试流程：不同机型、系统、流程逻辑
- 对于每次出现的崩溃做记录、避免重复错误
- 记录并上传崩溃日志（比如 bugly）
- 代码健壮性
  - 逻辑正确
  - 内存、性能
  - 预防式编码，代码中对于异常的保护判断
- 补救机制
  - 定期查看日志

## 延伸阅读
- [Creating an issue template for your repository](https://help.github.com/articles/creating-an-issue-template-for-your-repository/)
- [Issue and Pull Request templates](https://github.com/blog/2111-issue-and-pull-request-templates)
- [如何写一份良好的 Bug 报告](https://mp.weixin.qq.com/s?__biz=MjM5MzA0OTkwMA==&mid=210478795&idx=2&sn=148b793fcad9f7e768e8cacc3cb1b1b3&mpshare=1&scene=1&srcid=07101lOEzlJSRG5fSmsXnhZW#rd)
