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
  }
  
  // MARK: - Setup Methods
  fileprivate func setupTableView() {
//    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
    tableView.tableFooterView = UIView()
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
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
}
