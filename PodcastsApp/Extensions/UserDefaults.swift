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
  static let downloadedEpisodesKey = "downloadedEpisodesKey"
  
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
  
  func downloadEpisode(episode: Episode) {
    do {
      var episodes = downloadedEpisodes()
      episodes.append(episode)
      let data = try JSONEncoder().encode(episodes)
      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
    } catch let encodeError {
      print("Failed to encode:", encodeError)
    }    
  }
  
  func downloadedEpisodes() -> [Episode] {
    guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
    
    do {
      let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
      return episodes
    } catch let decodeError {
      print("Failed to decode:", decodeError)
    }
    return []
  }
}
