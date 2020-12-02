//
//  DownloadsController.swift
//  PodcastsApp
//
//  Created by David on 2020/12/2.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
  // MARK: - Instance Properties
  fileprivate let cellId = "CellId"
  
  var episodes = UserDefaults.standard.downloadedEpisodes()
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    episodes = UserDefaults.standard.downloadedEpisodes()
    tableView.reloadData()
  }
  
  // MARK: - Helper Methods
  fileprivate func setupTableView() {
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  // MARK: - UITableViewDataSource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
    cell.episode = self.episodes[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
}
