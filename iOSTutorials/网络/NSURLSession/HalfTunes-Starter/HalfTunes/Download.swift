//
//  Download.swift
//  HalfTunes
//
//  Created by ShannonChen on 2018/1/6.
//  Copyright © 2018年 Ray Wenderlich. All rights reserved.
//

import Foundation


/// 表示下载状态的 model
class Download {
  
  // 要下载的 track
  var track: Track
  init(track: Track) {
    self.track = track
  }
  
  // Download service sets these values:
  var task: URLSessionDownloadTask?
  var isDownloading = false
  var resumeData: Data?  // 停止下载时，已经下载好的数据，如果服务器支持断点下载的话，可以在暂停后用这个数据连续下载
  
  // Download delegate sets this value:
  var progress: Float = 0
  
}
