/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

// 下载文件，存储到本地
// 取消、暂停、开始下载
class DownloadService {

  // SearchViewController 中创建 downloadsSession
  var downloadsSession: URLSession!
  var activeDownloads: [URL: Download] = [:]

  // MARK: - 给 TrackCell delegate 方法调用的下载相关的方法

  func startDownload(_ track: Track) {
    
    let download = Download(track: track)
    
    download.task = downloadsSession.downloadTask(with: track.previewURL)
    
    download.task!.resume()
    
    download.isDownloading = true
    
    activeDownloads[download.track.previewURL] = download
    
    
  }
  // TODO: previewURL is http://a902.phobos.apple.com/...
  // why doesn't ATS prevent this download?

  // 暂停下载任务：先取消，然后保存下载好的数据
  /*
   https://developer.apple.com/documentation/foundation/urlsessiondownloadtask/1411634-cancel
   A download can be resumed only if the following conditions are met:
   - 自从上次请求后，该资源没有被改变过
   - 这个下载任务是一个 HTTP 或者 HTTPS 的 GET 请求
   - 服务器在响应头里面提供了 ETag 或者 Last-Modified，或者两者都提供了
   - 服务器支持 byte-range 的请求
   - 本地临时文件没有因为磁盘空间压力而被系统删除
   
 */
  func pauseDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL] else { return }
    if download.isDownloading {
      download.task?.cancel(byProducingResumeData: { data in
        download.resumeData = data
      })
      download.isDownloading = false
    }
  }

  // 取消下载任务
  func cancelDownload(_ track: Track) {
    if let download = activeDownloads[track.previewURL] {
      download.task?.cancel()
      activeDownloads[track.previewURL] = nil
    }
  }

  // 开始下载任务
  func resumeDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL] else {
      return
    }
    
    // 创建下载任务
    if let resumeData = download.resumeData {
      // 断点续传下载
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
    } else {
      // 从 0 开始下载
      download.task = downloadsSession.downloadTask(with: download.track.previewURL)
    }
    
    // 开始下载
    download.task!.resume()
    download.isDownloading = true
  }

}
