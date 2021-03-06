//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
  // MARK: - Instance Properties
  var podcasts = [Podcast]()
  let cellId = "CellId"  
  let searchController = UISearchController(searchResultsController: nil)
  
  var timer: Timer?
  
  var podcastSearchView = Bundle.main.loadNibNamed("PodcastsSearchingView", owner: self, options: nil)?.first as? UIView
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSearchBar()
    setupTableView()
    
    searchBar(searchController.searchBar, textDidChange: "Apple")
  }
  
  // MARK: - Setup Methods
  fileprivate func setupSearchBar() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }
  
  fileprivate func setupTableView() {
    tableView.tableFooterView = UIView()
    let nib = UINib(nibName: "PodcastCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  // MARK: - UISearchBarDelegate Methods
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    podcasts = []
    tableView.reloadData()
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
      APIService.shared.fetchPodcasts(searchText: searchText) { podcasts in
        self.podcasts = podcasts
        self.tableView.reloadData()
      }
    })    
  }
  
  // MARK: - UITableViewDataSource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
    let podcast = self.podcasts[indexPath.row]
    cell.podcast = podcast
    return cell
  }
  
  // MARK: - UITableViewDelegate Methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episodesController = EpisodesController()
    let podcast = self.podcasts[indexPath.row]
    episodesController.podcast = podcast
    navigationController?.pushViewController(episodesController, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.text = "Please enter a Search Term"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    return label
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? 250 : 0
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return podcastSearchView
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 200 : 0
  }
}

