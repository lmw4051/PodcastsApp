//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
  // MARK: - Instance Properties
  var podcast: Podcast? {
    didSet {
      navigationItem.title = podcast?.trackName
      fetchEpisodes()
    }
  }
  
  var episodes = [Episode]()
  
  fileprivate let cellId = "cellId"
  
  let favoritedPodcastKey = "favoritedPodcastKey"
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupNavigationBarButtons()
  }
  
  // MARK: - Setup Methods
  fileprivate func setupTableView() {
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
    tableView.tableFooterView = UIView()
  }
  
  fileprivate func setupNavigationBarButtons() {
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
      UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
    ]
  }
  
  @objc func handleSaveFavorite() {
    print("handleSaveFavorite")
    
    guard let podcast = self.podcast else { return }
    
    // Transform Podcast into Data
    let data = NSKeyedArchiver.archivedData(withRootObject: podcast)
    UserDefaults.standard.set(data, forKey: favoritedPodcastKey)
  }
  
  @objc func handleFetchSavedPodcasts() {
    print("handleFetchSavedPodcasts")
    let value = UserDefaults.standard.value(forKey: favoritedPodcastKey) as? String
    print(value ?? "")
    
    // Get the Podcast object from NSUserDefaults
    guard let data = UserDefaults.standard.data(forKey: favoritedPodcastKey) else { return }
    let podcast = NSKeyedUnarchiver.unarchiveObject(with: data) as? Podcast
    print(podcast?.trackName, podcast?.artistName)
  }
  
  // MARK: - Parser
  fileprivate func fetchEpisodes() {
    guard let feedUrl = podcast?.feedUrl else { return }
    
    APIService.shared.fetchEpisodes(feedUrl: feedUrl) { episodes in
      self.episodes = episodes
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: - UITableViewDataSource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    let episode = episodes[indexPath.row]
    cell.episode = episode
    return cell
  }
  
  // MARK: - UITableViewDelegate Methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episode = self.episodes[indexPath.row]
    UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)        
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    activityIndicatorView.color = .darkGray
    activityIndicatorView.startAnimating()
    return activityIndicatorView
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return episodes.isEmpty ? 200 : 0
  }
}
