//
//  Episode.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
  let title: String
  let pubDate: Date
  let description: String
  var imageUrl: String?
  
  init(feedItem: RSSFeedItem) {
    self.title = feedItem.title ?? ""
    self.pubDate = feedItem.pubDate ?? Date()
    self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
    self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
  }
}
