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
  let trackName: String
  let artistName: String
}
