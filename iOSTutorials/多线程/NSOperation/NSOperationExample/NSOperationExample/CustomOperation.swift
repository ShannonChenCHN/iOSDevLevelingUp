//
//  CustomOperation.swift
//  NSOperationExample
//
//  Created by ShannonChen on 2017/12/19.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

import Foundation

// https://blog.cnbluebox.com/blog/2014/07/01/cocoashen-ru-xue-xi-nsoperationqueuehe-nsoperationyuan-li-he-shi-yong/
// 可以通过重写 main 或者 start 方法 来定义自己的 operations
class CustomOperation: Operation {
    var identifier: String!
    var finishedFlag: Bool! = false
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // 如果你希望拥有更多的控制权，或者想在一个操作中可以执行异步任务，那么就重写 start 方法, 但是注意：这种情况下，你必须手动管理操作的状态， 只有当发送 isFinished 的 KVO 消息时，才认为是 operation 结束
    // 当实现了start方法时，默认会执行start方法，而不执行main方法，因为 Operation 抽象类内部是通过 start 方法调用 main 方法的
//    override func start() {
//
//        print(self.identifier)
//        finishedFlag = true
//
//    }
    
    // 使用 main 方法非常简单，开发者不需要管理一些状态属性（例如 isExecuting 和 isFinished），当 main 方法返回的时候，这个 operation 就结束了。
    // 这种方式使用起来非常简单，但是灵活性相对重写 start 来说要少一些， 因为main方法执行完就认为operation结束了，所以一般可以用来执行同步任务。
    override func main() {
        
        let deadlineTime = DispatchTime.now() + .seconds(4)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            print(self.identifier)
        }
    
        print(self.identifier + "xxx")
    }
    
//    override var isFinished: Bool {
//        get {
//            return finishedFlag
//        }
//    }
    
}
