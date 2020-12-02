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

// Use class for NSCoding Protocol
// Need to conform NSObject, otherwise the app will crash
class Podcast: NSObject, Decodable, NSCoding {
  func encode(with coder: NSCoder) {
    print("Trying to transform Podcast into Data")
    coder.encode(trackName ?? "", forKey: "trackNameKey")
    coder.encode(artistName ?? "", forKey: "artistNameKey")
    coder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
  }
  
  required init?(coder: NSCoder) {
    print("Trying to turn Data into Podcast")
    self.trackName = coder.decodeObject(forKey: "trackNameKey") as? String
    self.artistName = coder.decodeObject(forKey: "artistNameKey") as? String
    self.artworkUrl600 = coder.decodeObject(forKey: "artworkKey") as? String
  }
  
  var trackName: String?
  var artistName: String?
  var artworkUrl600: String?
  var trackCount: Int?
  var feedUrl: String?
}
