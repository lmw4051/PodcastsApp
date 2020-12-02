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
    setupObservers()
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
  
  fileprivate func setupObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
  }
  
  @objc fileprivate func handleDownloadProgress(notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: Any] else { return }
    guard let progress = userInfo["progress"] as? Double else { return }
    guard let title = userInfo["title"] as? String else { return }
    print(progress, title)
    
    guard let index = self.episodes.firstIndex(where: { $0.title == title }) else { return }
    let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
    cell?.progressLabel.text = "\(Int(progress * 100))%"
    cell?.progressContainerView.isHidden = false
    
    if progress == 1 {
      cell?.progressContainerView.isHidden = true
    }
  }
  
  @objc fileprivate func handleDownloadComplete(notification: Notification) {
    guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
    guard let index = self.episodes.firstIndex(where: { $0.title == episodeDownloadComplete.episodeTitle }) else { return }
    self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
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
  
  // MARK: - UITableViewDelegate Methods
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let episode = self.episodes[indexPath.row]
    episodes.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    UserDefaults.standard.deleteEpisode(episode: episode)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episode = self.episodes[indexPath.row]
    
    if episode.fileUrl != nil {
      UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
    } else {
      let alertController = UIAlertController(title: "File URL not found",
                                              message: "Cannot find local file, play using stream url instead",
                                              preferredStyle: .actionSheet)
      alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
      }))
      
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      present(alertController, animated: true)
    }
  }
}
