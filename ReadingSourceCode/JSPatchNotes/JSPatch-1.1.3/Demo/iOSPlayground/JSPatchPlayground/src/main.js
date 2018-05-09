include('JPDemoController.js');

defineClass('JPRootViewController', {
           
    viewWillAppear: function(animated) {
        self.super().viewWillAppear(animated);
            
        // 在 block 内部使用 self
        var jsSelf = self;
        self.callBlock(block(
                                 function(){
                                    jsSelf.doSomething();
                                 }
                             )
                       );
    },
            
    showController: function() {
        var ctrl = JPDemoController.alloc().init();
        self.navigationController().pushViewController_animated(ctrl, NO);
    }
            
    
});
