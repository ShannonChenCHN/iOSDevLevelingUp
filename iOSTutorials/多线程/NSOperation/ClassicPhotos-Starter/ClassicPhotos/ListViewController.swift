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
    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Classic Photos"
        
        fetchPhotoDetails()
    }
    
    func fetchPhotoDetails() {
        let request = URLRequest(url: dataSourceURL!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) in
            if data != nil {
                let datasourceDictionary = try? PropertyListSerialization.propertyList(from: data!, options: .mutableContainers, format: nil) as? NSDictionary
                
                for(key, value) in datasourceDictionary! ?? NSDictionary() {
                    let name = key as? String
                    let url = URL(string: value as? String ?? "")
                    if name != nil && url != nil {
                        let photoRecord = PhotoRecord(name:name!, url:url!)
                        self.photos.append(photoRecord)
                    }
                }
                
                self.tableView.reloadData()
            }
            
            if error != nil {
                let alert = UIAlertView.init(title: "Oops!", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        
    }
    
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        //1 显示 loading
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        //2 取出图片 URL 相关数据
        let photoDetails = photos[indexPath.row]
        
        //3 设置 UI 展示
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        //4 根据状态进行操作
        switch (photoDetails.state){
        case .Filtered:
            indicator.stopAnimating()
        case .Failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .New, .Downloaded:
            indicator.startAnimating()
            
            // 当用户拖拽滚动列表时，我们将取消正在下载的、不可见的任务，同时等到停止滑动时，开启可见的、还未下载的任务和恢复暂停了的任务
            // 如果不这样做的话，就会导致图片加载任务总是按照加入队列的先后顺序来执行的
            if tableView.isDragging && tableView.isDecelerating {
                self.startOperationsForPhotoRecord(photoDetails, indexPath:indexPath)
            }
        }
        
        return cell
    }
    
    
    // 根据状态决定当前处理步骤
    func startOperationsForPhotoRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath){
        switch (photoDetails.state) {
        case .New:
            startDownloadForRecord(photoDetails, indexPath: indexPath)
        case .Downloaded:
            startFiltrationForRecord(photoDetails, indexPath: indexPath)
        default:
            print("do nothing")
        }
    }
    
    /// 下载
    func startDownloadForRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath){
        //1 如果任务已经创建了就不再重复创建
        // 如果已经下载了的话， Photo Record 的状态会变成 Downloaded，也不会走到这里来
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        //2 创建下载 operation
        let downloader = ImageDownloader(photoRecord: photoDetails)
        
        //3 下载任务完成
        downloader.completionBlock = {
            // 判断是否已经被取消
            if downloader.isCancelled {
                return
            }
            // 回到主线程
            DispatchQueue.main.async(execute: {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            })
        }
        
        //4 记录当前正在下载的任务，下载完成后移除
        pendingOperations.downloadsInProgress[indexPath] = downloader
        
        //5 添加 operation 到队列中
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    /// 滤镜
    func startFiltrationForRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath){
        guard pendingOperations.filtrationsInProgress[indexPath] == nil else {
            return
        }
        
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            })
            
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
    
}

/// UIScrollViewDelegate
extension ListViewController {
    
    // 开始拖拽
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        //1 开始拖拽时，取消所有操作
        suspendAllOperations()
    }

    // 停止拖拽
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2 停止拖拽并且没有减速时，开始加载可见 cell 的图片和暂停的任务
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }

    // 停止减速
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    // 暂停所有还未开始的任务
    func suspendAllOperations () {
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
    }
    
    // 启动所有还未开始的任务
    func resumeAllOperations () {
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }
    
    
    // 加载所有可见 cell 的图片
    func loadImagesForOnscreenCells () {
        //1 取出所有可见 cell 的索引
        if let pathsArray = tableView.indexPathsForVisibleRows {
            //2 获取所有正在执行的 operation
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            allPendingOperations.formUnion(pendingOperations.filtrationsInProgress.keys)
            
            //3 取消不可见的 cell 的图片加载 operation
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            //4 开启可见的 cell 的图片加载 operation，如果已经开始了就不用开启
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            // 5 取消不可见的 cell 的图片加载 operation
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            
            // 6 开启可见的 cell 的图片加载 operation
            for indexPath in toBeStarted {
                let recordToProcess = self.photos[indexPath.row]
                startOperationsForPhotoRecord(recordToProcess, indexPath: indexPath)
            }
        }
    }
}
