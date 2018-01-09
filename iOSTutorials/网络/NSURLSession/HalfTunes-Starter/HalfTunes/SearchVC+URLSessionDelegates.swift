//
//  SearchVC+URLSessionDelegates.swift
//  HalfTunes
//
//  Created by ShannonChen on 2018/1/3.
//  Copyright © 2018年 Ray Wenderlich. All rights reserved.
//

import Foundation



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
  
}
