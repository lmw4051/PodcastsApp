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
  
  // MARK: - Helper Methods
  fileprivate func setupNavigationBarButtons() {
    let savedPodcasts = UserDefaults.standard.savedPodcasts()
    
    let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
    
    if hasFavorited {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    } else {
      navigationItem.rightBarButtonItems = [
        UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
//        UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
      ]
    }    
  }
  
  fileprivate func showBadgeHighlight() {
    UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
  }
  
  // MARK: - Selector Methods
  @objc func handleSaveFavorite() {
    print("handleSaveFavorite")
    
    guard let podcast = self.podcast else { return }
        
    // Transform Podcast into Data
    var listOfPodcasts = UserDefaults.standard.savedPodcasts()
    listOfPodcasts.append(podcast)
    let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
    UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    
    showBadgeHighlight()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
  }
  
  @objc func handleFetchSavedPodcasts() {
    // Get the Podcast object from NSUserDefaults
    guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return }
    
    let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
    
    savedPodcasts?.forEach({ podcast in
      print(podcast.trackName ?? "")
    })
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
  
  // MARK: - UITableViewDelegate Methods
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
      print("Downloading episode info UserDefaults")
      let episode = self.episodes[indexPath.row]
      UserDefaults.standard.downloadEpisode(episode: episode)
      
      APIService.shared.downloadEpisode(episode: episode)
    }
    
    return [downloadAction]
  }
}
