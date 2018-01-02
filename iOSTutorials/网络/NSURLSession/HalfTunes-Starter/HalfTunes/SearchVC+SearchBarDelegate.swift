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
import UIKit


// MARK: - 搜索页面搜索工具条的 delegate 方法
extension SearchViewController: UISearchBarDelegate {

  @objc func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }

  /// 点击键盘上的搜索按钮
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    dismissKeyboard() // 收起键盘
    
    guard let searchText = searchBar.text, !searchText.isEmpty else { return }
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true  // 显示网络加载状态标识
    
    // 发起搜索请求
    queryService.getSearchResults(searchTerm: searchText) { results, errorMessage in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let results = results {
        self.searchResults = results
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
      }
      if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
    }
  }

  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    view.addGestureRecognizer(tapRecognizer)
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    view.removeGestureRecognizer(tapRecognizer)
  }
}
