//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//


/**
 
 https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift
 
 最耗时的3个操作：
 1. 下载图片 URL list
 2. 下载图片
 3. 使用 Core Image 给图片加滤镜
 
 */

import UIKit
import CoreImage

let dataSourceURL = URL.init(string: "http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")


class ListViewController: UITableViewController {
    
    // 下载保存有图片 URL 信息的文件
    lazy var photos = NSDictionary.init(contentsOf: dataSourceURL! as URL) ?? NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Classic Photos"
    }
    
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        let rowKey = photos.allKeys[indexPath.row] as! String
        
        var image : UIImage?
        if let imageURL = URL(string: photos[rowKey] as! String) {
            
            // 下载图片
            if let imageData = try? Data.init(contentsOf: imageURL) {
                // 1
                let unfilteredImage = UIImage.init(data: imageData)
                
                // 2 添加滤镜效果
                image = self.applySepiaFilter(image: unfilteredImage!)
            }
        }
        
        // Configure the cell...
        cell.textLabel?.text = rowKey
        if image != nil {
            cell.imageView?.image = image!
        }
        
        return cell
    }
    
    
    func applySepiaFilter(image: UIImage) -> UIImage? {
        
        let inputImage = CIImage.init(data: UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        
        if let outputImage = filter?.outputImage {
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            return UIImage.init(cgImage: outImage!)
        }
        return nil
        
    }
    
}
