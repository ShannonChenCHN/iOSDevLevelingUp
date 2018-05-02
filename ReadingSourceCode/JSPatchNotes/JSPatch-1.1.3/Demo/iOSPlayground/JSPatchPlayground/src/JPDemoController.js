require('UILabel, UIColor, UIFont, UIScreen, UIImageView, UIImage', 'NSMutableArray', 'JPRootViewController') // 导入 Objective-C 系统类

var screenWidth = UIScreen.mainScreen().bounds().width;
var screenHeight = UIScreen.mainScreen().bounds().height;

// 定义一个类
defineClass('JPDemoController: UIViewController', ['jsTitle'],

// 定义实例方法
{
    viewDidLoad: function() {
        self.super().viewDidLoad();
            
        self.view().setBackgroundColor(UIColor.whiteColor()); // 获取/修改 Property 等于调用这个 Property 的 getter / setter 方法
        
        // NSMutableArray
        var array = NSMutableArray.array();
        array.addObject("JSPatch");
        
        // JS 数组
        var jsArray = array.toJS();
        jsArray.push("dynamicProperty");
            
        // 打印调试
        console.log(jsArray);
        
        // 修改属性
        self.setJsTitle(jsArray[1]);
        
        // 添加 View
        var size = 120;
        var imgView = UIImageView.alloc().initWithFrame({x: (screenWidth - size)/2, y: 150, width: size, height: size});
        imgView.setImage(UIImage.imageWithContentsOfFile(resourcePath('apple.png')));
        self.view().addSubview(imgView);
            
        var label = UILabel.alloc().initWithFrame({x: 0, y: 310, width: screenWidth, height: 30});
        label.setText(array.objectAtIndex(0));
        label.setTextAlignment(1);
        label.setFont(UIFont.systemFontOfSize(25));
        self.view().addSubview(label);
            
            
        var text = UILabel.alloc().initWithFrame({x: 0, y: 400, width: screenWidth, height: 50});
        text.setText(self.jsTitle());
        text.setTextAlignment(1);
        text.setFont(UIFont.systemFontOfSize(20));
        self.view().addSubview(text);
            
        // 调用类方法
//        JPDemoController.showAlert();
        JPDemoController.performSelector_withObject("showAlert", null);
            
        // 将 JS 函数包装成 block 传给原生调用
        JPRootViewController.request(block("NSString *, BOOL", function(ctn, succ) {
                                           if (succ) console.log(ctn);  //output: I'm content
        }));
            
        // JS 中可以直接调用原生的 block
        var blk = JPRootViewController.genBlock();
        blk({v: "0.0.1"});  //output: I'm JSPatch, version: 0.0.1
    },
            
},
            
// 定义类方法
{
    showAlert: function() {
            var alertView = require('UIAlertView')
            .alloc()
            .initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles(
                                                                                "Alert",
                                                                                "Hello, Shanghai!",
                                                                                self,
                                                                                "OK",
                                                                                null
                                                                                );
            alertView.show();
    }
            
})
