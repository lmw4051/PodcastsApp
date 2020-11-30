//
//  APIService.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
  let baseiTunesSearchURL = "https://itunes.apple.com/search"
  
  static let shared = APIService()
  
  func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
    print("Searching for podcasts...")
    
    let parameters = ["term": searchText, "media": "podcast"]
    
    Alamofire.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { dataResponse in
      if let error = dataResponse.error {
        print("Failed to load data", error)
        return
      }

      guard let data = dataResponse.data else { return }

      do {
        let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
        print(searchResult.resultCount)
        completionHandler(searchResult.results)
      } catch let decodeErr {
        print("Failed to decode:", decodeErr)
      }
    }
  }
  
  func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
    let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
    
    guard let url = URL(string: secureFeedUrl) else { return }
    let parser = FeedParser(URL: url)
    
    parser?.parseAsync(result: { result in
      print("Successfully parse feed:", result.isSuccess)
      
      if let error = result.error {
        print("Failed to parse XML feed:", error)
        return
      }
      
      guard let feed = result.rssFeed else { return }
      
      let episodes = feed.toEpisodes()
      completionHandler(episodes)
    })
  }
}
