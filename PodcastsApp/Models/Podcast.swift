//
//  Podcast.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

struct SearchResults: Decodable {
  let resultCount: Int
  let results: [Podcast]
}

struct Podcast: Decodable {
  var trackName: String?
  var artistName: String?
  var artworkUrl600: String?
  var trackCount: Int?
  var feedUrl: String?
}
