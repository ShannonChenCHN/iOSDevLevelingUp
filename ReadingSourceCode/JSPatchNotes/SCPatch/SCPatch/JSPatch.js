var global = this;

// 定义原函数
Object.defineProperty(Object.prototype, '__call', {
  value: function(methodName) {
   if (!this.object && !this.className) return this[methodName].bind(this);

    var self = this;
    return function() {
      var args = Array.prototype.slice.call(arguments);
      self.object = callObjCMethod(self.className, self.object, methodName, args);
      return self;
    }
  },
});

var require = function(objcClsName) {

  if (!global[objcClsName]) {

    var obj = new Object();
    obj.className = objcClsName;

/*
    obj.alloc = function() {
         obj.object = callObjCClassMethod(objcClsName, 'alloc');
         return obj;
    }

    obj.init = function() {

        obj.object = callObjCInstanceMethod(obj.object, 'init');
        return obj;
    }

*/

    global[objcClsName] = obj;
  }


  return obj;

}

/*
关于 JS 的一些问题：
1. Object.defineProperty 的用法:https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
2. this，如何解决 this 的作用范围问题，比如说在一个函数内引用外面的 this ？就像上面的 `var global = this;`
3. Object.prototype

*/
