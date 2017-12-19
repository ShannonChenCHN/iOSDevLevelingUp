//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by ShannonChen on 2017/12/19.
//  Copyright © 2017年 raywenderlich. All rights reserved.
//

import UIKit


/// 一张图片的状态
enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
}

/// 图片的 model
class PhotoRecord {
    let name: String
    let url: URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}


/// 管理待处理的任务
class PendingOperations {
    
    // 下载任务
    lazy var downloadsInProgress = [IndexPath: Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // 滤镜处理任务
    lazy var filtrationsInProgress = [IndexPath: Operation]()
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

/// 图片下载 operation
class ImageDownloader: Operation {
    //1 每个任务对应一张图片
    let photoRecord: PhotoRecord
    
    //2 指定初始化方法
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    //3 重写 main 方法，执行任务
    override func main() {
        //4 开始执行任务前务必要检查 operation 是否已经被取消
        if self.isCancelled {
            return
        }
        
        //5 下载图片数据
        let imageData = try? Data.init(contentsOf: self.photoRecord.url)
        
        //6 再次检查取消状态
        if self.isCancelled {
            return
        }
        
        //7 下载完成后的处理：设置图片，更新状态
        if let dataCount = imageData?.count, dataCount > 0 {
            self.photoRecord.image = UIImage(data:imageData!)
            self.photoRecord.state = .Downloaded
        }
        else
        {
            self.photoRecord.state = .Failed
            self.photoRecord.image = UIImage(named: "Failed")
        }
    }
}


/// 图片滤镜处理 operation
class ImageFiltration: Operation {
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    // 执行任务
    override func main () {
        if self.isCancelled {
            return
        }
        
        if self.photoRecord.state != .Downloaded {
            return
        }
        
        if let filteredImage = self.applySepiaFilter(self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .Filtered
        }
    }
    
    // 添加滤镜效果
    func applySepiaFilter(_ image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        if self.isCancelled {
            return nil
        }
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter?.outputImage
        
        if self.isCancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        return returnImage
    }
}

