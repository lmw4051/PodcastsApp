//
//  UserDefaults.swift
//  PodcastsApp
//
//  Created by David on 2020/12/2.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

extension UserDefaults {
  static let favoritedPodcastKey = "favoritedPodcastKey"
  
  func savedPodcasts() -> [Podcast] {
    guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
    guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return [] }
    
    return savedPodcasts
  }
  
  func deletePodcast(podcast: Podcast) {
    let podcasts = savedPodcasts()
    let filteredPodcasts = podcasts.filter { podcast -> Bool in
      return podcast.trackName != podcast.trackName && podcast.artistName != podcast.artistName
    }
    
    let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
    UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
  }
}
