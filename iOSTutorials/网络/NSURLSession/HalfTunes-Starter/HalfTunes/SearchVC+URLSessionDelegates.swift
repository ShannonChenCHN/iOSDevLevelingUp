//
//  SearchVC+URLSessionDelegates.swift
//  HalfTunes
//
//  Created by ShannonChen on 2018/1/3.
//  Copyright © 2018年 Ray Wenderlich. All rights reserved.
//

import Foundation



// MARK: -
extension SearchViewController: URLSessionDownloadDelegate {
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    print("Finished downloading to \(location).")
  }
  
}
