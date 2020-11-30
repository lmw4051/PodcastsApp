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
  var podcasts = [
    Podcast(trackName: "AskTheCEO", artistName: "Avrohom Gottheil"),
    Podcast(trackName: "IT Rockstars", artistName: "Scott Millar"),
  ]
  
  let cellId = "CellId"
  
  let searchController = UISearchController(searchResultsController: nil)
  
  fileprivate let enterSearchTermLabel: UILabel = {
    let label = UILabel()
    label.text = "Please enter search term above..."
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 20)
    return label
  }()
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSearchBar()
    setupTableView()
  }
  
  // MARK: - Setup Methods
  fileprivate func setupSearchBar() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }
  
  fileprivate func setupTableView() {
//    tableView.register(PodcastCell.self, forCellReuseIdentifier: cellId)
    let nib = UINib(nibName: "PodcastCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: cellId)
  }
  
  // MARK: - UISearchBarDelegate Methods
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    APIService.shared.fetchPodcasts(searchText: searchText) { podcasts in
      self.podcasts = podcasts
      self.tableView.reloadData()
    }        
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
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
}

