//
//  SearchVC+URLSessionDelegates.swift
//  HalfTunes
//
//  Created by ShannonChen on 2018/1/3.
//  Copyright © 2018年 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit


// MARK: 下载回调
extension SearchViewController: URLSessionDownloadDelegate {
  
  // 下载完成时回调
  // 将文件从临时目录移到沙盒中
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    
    // 获取下载链接
    guard let sourceURL = downloadTask.originalRequest?.url else {
      return
    }
    
    // 取出下载的模型，并将其从字典中移除掉
    let download = downloadService.activeDownloads[sourceURL]
    downloadService.activeDownloads[sourceURL] = nil
    
    // 获取目标存储路径
    let destinationURL = localFilePath(for: sourceURL)
    print(destinationURL)
    
    // 复制下载好的文件到目标路径下
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: destinationURL)
    do {
      try fileManager.copyItem(at: location, to: destinationURL)
      download?.track.downloaded = true
    } catch let error {
      print("Could not copy file to disk: \(error.localizedDescription)")
    }
    
    // 更新 cell
    if let index = download?.track.index {
      DispatchQueue.main.async {
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
      }
    }
    
  }
  
  // 下载进度
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    // 获取下载链接
    guard let url = downloadTask.originalRequest?.url, let download = downloadService.activeDownloads[url] else {
        return
    }
    
    // 设置 download 对象的下载进度
    download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    
    // 文件总大小
    let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
    
    // 更新 UI
    DispatchQueue.main.async {
      if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index,
                                                                 section: 0)) as? TrackCell {
        trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
      }
    }

  }
  
  // Standard background session handler
  /* 什么是后台传输（Background Transfers）？
   后台传输是指，当应用程序在后台运行甚至崩溃后，下载任务仍然可以继续执行。
   
   运行原理：当 app 没有运行时，系统会在 app 外自动开启一个单独的后台驻留程序，来管理后台传输任务，当后台下载任务在执行时，系统会通过发送相应的代理消息给 app。
           如果在活跃的传输过程中应用终止运行，下载任务会不受影响地在后台继续执行。
           当一个后台下载任务完成后，后台驻留程序会在后台重新启动应用，重启后的应用会重新创建后台 session，来接受相应的 completion 代理消息，以及执行一些必需的动作，比如保存下载好的文件到磁盘。
   
   注：如果用户通过双击 home 键强行退出应用，系统会取消所有的下载任务，而且不会再尝试重启应用。
   
   实现后台传输的步骤：
   1. 在初始化 URLSession 时，通过 background(withIdentifier: ) 方法创建一个特殊的 URLSessionConfiguration；
   2. 在 AppDelegate 中实现 application(_:handleEventsForBackgroundURLSession:)  方法，保存闭包 completionHandler；
   3. 在代理方法 urlSessionDidFinishEvents(forBackgroundURLSession:): 中，调用 AppDelegate 的 completionHandler；
   
 */
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        completionHandler()
      }
    }
  }
  
}
