require('UIView');
require('UIColor');

// 1. 调用 Objective-C 类的方法
var view = UIView.alloc().init();
var backgroundColor = UIColor.redColor();
view.setBackgroundColor(backgroundColor);

logInXcode(view.object);


// 为某个类新增方法


// 动态创建 Objective-C class
