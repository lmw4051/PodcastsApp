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
  let podcasts = [
    Podcast(trackName: "AskTheCEO", artistName: "Avrohom Gottheil"),
    Podcast(trackName: "IT Rockstars", artistName: "Scott Millar"),
  ]
  
  let cellId = "CellId"
  
  let searchController = UISearchController(searchResultsController: nil)
  
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupSearchBar()
  }
  
  // MARK: - Setup Methods
  fileprivate func setupTableView() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
  }
  
  fileprivate func setupSearchBar() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }
  
  // MARK: - UITableViewDataSource Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    let podcast = self.podcasts[indexPath.row]
    cell.textLabel?.text = "\(podcast.trackName)\n\(podcast.artistName)"
    cell.textLabel?.numberOfLines = -1
    cell.imageView?.image = #imageLiteral(resourceName: "appicon")
    return cell
  }
  
  // MARK: - UISearchBarDelegate Methods
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    let url = "https://itunes.apple.com/search?term=\(searchText)"
    Alamofire.request(url).responseData { dataResponse in
      if let error = dataResponse.error {
        print("Failed to load data")
        return
      }
      
      guard let data = dataResponse.data else { return }
      let str = String(data: data, encoding: .utf8)
      print(str)
    }
  }
}

