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

import UIKit


/// cell 的代理方法
protocol TrackCellDelegate {
  func pauseTapped(_ cell: TrackCell)
  func resumeTapped(_ cell: TrackCell)
  func cancelTapped(_ cell: TrackCell)
  func downloadTapped(_ cell: TrackCell)
}

class TrackCell: UITableViewCell {

  // Delegate identifies track for this cell,
  // then passes this to a download service method.
  var delegate: TrackCellDelegate?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var downloadButton: UIButton!
  
  // 暂停/开始/继续
  @IBAction func pauseOrResumeTapped(_ sender: AnyObject) {
    if(pauseButton.titleLabel?.text == "Pause") {
      delegate?.pauseTapped(self)
    } else {
      delegate?.resumeTapped(self)
    }
  }
  
  // 取消下载
  @IBAction func cancelTapped(_ sender: AnyObject) {
    delegate?.cancelTapped(self)
  }
  
  // 点击下载按钮
  @IBAction func downloadTapped(_ sender: AnyObject) {
    delegate?.downloadTapped(self)
  }
  
  // 更新进度
  func updateDisplay(progress: Float, totalSize : String) {
    progressView.progress = progress
    progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
  }

  // 绑定数据
  func configure(track: Track, downloaded: Bool, download: Download?) {
    titleLabel.text = track.name
    artistLabel.text = track.artist

    // 显示/隐藏 下载控件： 暂停/继续，取消按钮，下载进度
    // Download 对象不为空，则代表正在下载中
    var showDownloadControls = false
    if let download = download {
      showDownloadControls = true
      let title = download.isDownloading ? "Pause" : "Resume"
      pauseButton.setTitle(title, for: .normal)
      progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
    }

    pauseButton.isHidden = !showDownloadControls
    cancelButton.isHidden = !showDownloadControls
    progressView.isHidden = !showDownloadControls
    progressLabel.isHidden = !showDownloadControls
    
    // 如果已经下载好了， cell 变成可点击状态，并且需要隐藏下载按钮
    selectionStyle = downloaded ? UITableViewCellSelectionStyle.gray : UITableViewCellSelectionStyle.none
    downloadButton.isHidden = downloaded || showDownloadControls
  }

}
