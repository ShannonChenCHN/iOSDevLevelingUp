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

// Runs query data task, and stores results in array of Tracks

/// 执行搜索请求任务，并将结果保存到 Tracks 数组中
class QueryService {

  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Track]?, String) -> ()

  var tracks: [Track] = []
  var errorMessage = ""

  // 默认的 URLSession 对象
  let defaultSession = URLSession(configuration: .default)
  
  // 每次搜索都会通过 URLSession 对象重新创建一个 data task
  var dataTask: URLSessionDataTask?

  /// 获取搜索结果
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    
    // 1 取消正在请求的 task
    dataTask?.cancel()
    
    // 2 拼接 URL
    if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
      urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
      
      // 3 optional-bind
      guard let url = urlComponents.url else { return }
     
      // 4 根据 URL 创建 data task
      dataTask = defaultSession.dataTask(with: url) { data, response, error in
        defer { self.dataTask = nil } // closure 执行完后，置空 data task
        
        // 5 请求成功则解析数据，将 data 转成 track 数组
        if let error = error {
          self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if let data = data,
          let response = response as? HTTPURLResponse,
          response.statusCode == 200 {
          self.updateSearchResults(data)
          
          // 6 回到主队列，回调 closure，返回数据
          DispatchQueue.main.async {
            completion(self.tracks, self.errorMessage)
          }
        }
      }
      
      // 7 开启请求任务
      dataTask?.resume()
    }
  }

  /// 解析搜索结果数据：Data -> Dictionary
  fileprivate func updateSearchResults(_ data: Data) {
    var response: JSONDictionary?
    
    // 先删除原来的所有数据
    tracks.removeAll()

    // JSON 解析：Data -> Dictionary
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return
    }
    
    guard let array = response!["results"] as? [Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    
    // 将 Dictionary 转成自定义对象
    var index = 0
    for trackDictionary in array {
      if let trackDictionary = trackDictionary as? JSONDictionary,
        let previewURLString = trackDictionary["previewUrl"] as? String,
        let previewURL = URL(string: previewURLString),
        let name = trackDictionary["trackName"] as? String,
        let artist = trackDictionary["artistName"] as? String {
        tracks.append(Track(name: name, artist: artist, previewURL: previewURL, index: index))
        index += 1
      } else {
        errorMessage += "Problem parsing trackDictionary\n"
      }
    }
  }

}
