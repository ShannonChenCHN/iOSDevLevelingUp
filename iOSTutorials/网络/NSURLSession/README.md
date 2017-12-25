
# 网络编程之 NSURLSession





问题：
1. 什么是 URL Loading System？

2. NSURLConnection 与 NSURLSession 的区别？

3. 为什么 NSURLConnection 会被 NSURLSession 所替代？

4. 如何使用 NSURLConnection 和 NSURLSession

5. 何时需要使用以及如何使用 NSURLProtocol？

6. AFNetworking 为什么要对 NSURLConnection/NSURLSession 进行封装？它是如何封装的？

7. AFNetworking 2.x 和 AFNetworking 3.x 的区别是什么？

8. 为什么 SDWebImage 早期版本中使用 NSURLConnection 异步下载时，需要手动启动 Runloop 来实现线程的保活，而现在版本中使用 NSURLSession 时，却不需要呢？


### 参考：
- [NSURLSession and NSDefaultRunLoopMode](https://stackoverflow.com/questions/20098106/nsurlsession-and-nsdefaultrunloopmode)
- [NSURLSession与NSURLConnection区别](http://www.guiyongdong.com/2016/11/18/NSURLSession与NSURLConnection区别/)
- [NSURLSession VS. NSURLConnection](https://stackoverflow.com/questions/33919862/nsurlconnection-vs-nsurlsession)
http://www.jianshu.com/p/2bd9cb569fc2
