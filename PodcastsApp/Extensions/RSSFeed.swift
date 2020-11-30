//
//  RSSFeed.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import FeedKit

extension RSSFeed {
  func toEpisodes() -> [Episode] {
    let imageUrl = iTunes?.iTunesImage?.attributes?.href
    
    var episodes = [Episode]()
    
    items?.forEach({ feedItem in
      var episode = Episode(feedItem: feedItem)
      
      if episode.imageUrl == nil {
        episode.imageUrl = imageUrl
      }
      
      episodes.append(episode)
    })
    return episodes
  }
}
