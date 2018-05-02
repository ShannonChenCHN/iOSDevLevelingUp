#  JavaScriptCore


## 一、基本使用

### JSContext
JSContext 是运行 JavaScript 代码的环境。一个 JSContext 是一个全局环境的实例，如果你写过一个在浏览器内运行的 JavaScript，JSContext 类似于 window。

### JSValue

任何出自 JSContext 的值都被包裹在一个 JSValue 对象中。像 JavaScript 这样的动态语言需要一个动态类型，所以 JSValue 包装了每一个可能的 JavaScript 值：字符串和数字；数组、对象和方法；甚至错误和特殊的 JavaScript 值诸如 null 和 undefined。

JSValue 包括一系列方法用于访问其可能的值以保证有正确的 Foundation 类型，详见 https://developer.apple.com/documentation/javascriptcore/jsvalue?language=objc


### Objective-C 调用 JS

#### ### JS 调用 Objective-C

1. block

2. JSExport 协议

自定义一个继承 JSExport 的协议，同时让自定义类遵循该协议。

无论我们在 JSExport 里声明的属性，实例方法还是类方法，继承的协议都会自动的提供给任何 JavaScript 代码。

## 二、内存管理

JSContext 会对其 block 中的 对象强引用。

## 三、调试

可以使用 Safari 自带的调试工具进行调试。


## 参考

http://nshipster.cn/javascriptcore/
https://developer.apple.com/documentation/javascriptcore?language=objc
https://zhuanlan.zhihu.com/p/29663994
