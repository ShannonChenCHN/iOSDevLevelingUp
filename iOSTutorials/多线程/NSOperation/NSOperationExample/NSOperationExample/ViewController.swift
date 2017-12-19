//
//  ViewController.swift
//  NSOperationExample
//
//  Created by ShannonChen on 2017/12/15.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let operation_1 = CustomOperation.init(identifier: "1")
        let operation_2 = CustomOperation.init(identifier: "2")
        let operation_3 = CustomOperation.init(identifier: "3")
        
        operation_2.addDependency(operation_1)
        operation_3.addDependency(operation_2)
        
        let operationQueue = OperationQueue()
        operationQueue.addOperation(operation_1)
        operationQueue.addOperation(operation_2)
        operationQueue.addOperation(operation_3)
        
        
    }



}

