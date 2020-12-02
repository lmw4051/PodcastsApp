//
//  MainTabBarController.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  // MARK: - Instance Properties
  var maximizedTopAnchorConstraint: NSLayoutConstraint!
  var minimizedTopAnchorConstraint: NSLayoutConstraint!
  var bottomAnchorConstraint: NSLayoutConstraint!
  
  let playerDetailsView = PlayerDetailsView.initFromNib()
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    UINavigationBar.appearance().prefersLargeTitles = true
    tabBar.tintColor = .purple
    
    setupViewControllers()
    setupPlayerDetailsView()
  }
  
  func minimizePlayerDetails() {
    print("minimizePlayerDetails")
    maximizedTopAnchorConstraint.isActive = false
    // Set bottomAnchorConstraint.constant = view.frame.height
    // in the middle to prevent AutoLayout conflicts warning
    bottomAnchorConstraint.constant = view.frame.height
    minimizedTopAnchorConstraint.isActive = true
    
    // Set constant to view.frame.height for avoiding transparency
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
      
      if #available(iOS 13, *) {
        self.tabBar.frame.origin.y = self.view.frame.size.height - self.tabBar.frame.height
      } else {
        self.tabBar.transform = .identity
      }
      
      self.playerDetailsView.maximizedStackView.alpha = 0
      self.playerDetailsView.miniPlayerView.alpha = 1
    })
  }
  
  func maximizePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
    print("maximizePlayerDetails")
    // Set minimizedTopAnchorConstraint.isActive = false first
    // to present AutoLayout Conflicts warning
    minimizedTopAnchorConstraint.isActive = false
    maximizedTopAnchorConstraint.isActive = true
    // Set constant = 0 to show the playerDetailsView
    maximizedTopAnchorConstraint.constant = 0
    
    // Set constant to 0 in order to reset to the original one
    // instead of further down.
    bottomAnchorConstraint.constant = 0
    
    if episode != nil {
      playerDetailsView.episode = episode
    }
    
    playerDetailsView.playlistEpisodes = playlistEpisodes
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
      
      if #available(iOS 13, *) {
        self.tabBar.frame.origin.y = self.view.frame.size.height
      } else {
        self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)        
      }
      
      self.playerDetailsView.maximizedStackView.alpha = 1
      self.playerDetailsView.miniPlayerView.alpha = 0
    })
  }
  
  // MARK: - Setup Methods
  func setupViewControllers() {
    let layout = UICollectionViewFlowLayout()
    let favoritesController = FavoritesController(collectionViewLayout: layout)

    viewControllers = [
      generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
      generateNavigationController(with: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
      generateNavigationController(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
    ]
  }
  
  fileprivate func setupPlayerDetailsView() {
    print("setupPlayerDetailsView")
    view.insertSubview(playerDetailsView, belowSubview: tabBar)
    
    // Enables AutoLayout
    playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
    
    // Set playerDetailsView from the very bottom by setting constant = view.frame.height
    maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
    maximizedTopAnchorConstraint.isActive = true
        
    // Setting bottomAnchor constant to view.frame.height will increase height further down
    // thus prevent the transparency
    bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
    bottomAnchorConstraint.isActive = true
    
    minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
    //    minimizedTopAnchorConstraint.isActive = true
    
    playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
  }
  
  // MARK: - Helper Methods
  fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
    let navController = UINavigationController(rootViewController: rootViewController)
    rootViewController.navigationItem.title = title
    navController.tabBarItem.title = title
    navController.tabBarItem.image = image
    return navController
  }
}
