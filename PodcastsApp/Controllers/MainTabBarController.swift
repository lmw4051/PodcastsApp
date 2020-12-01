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
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    UINavigationBar.appearance().prefersLargeTitles = true
    tabBar.tintColor = .purple
    
    setupViewControllers()
    setupPlayerDetailsView()
    
    perform(#selector(maximizePlayerDetails), with: nil, afterDelay: 1)
  }
    
  @objc func minimizePlayerDetails() {
    print("minimizePlayerDetails")
    maximizedTopAnchorConstraint.isActive = false
    minimizedTopAnchorConstraint.isActive = true
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc func maximizePlayerDetails() {
    print("maximizePlayerDetails")
    maximizedTopAnchorConstraint.isActive = true
    // Set constant = 0 to show the playerDetailsView
    maximizedTopAnchorConstraint.constant = 0
    minimizedTopAnchorConstraint.isActive = false
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  // MARK: - Setup Methods
  func setupViewControllers() {
    viewControllers = [
      generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
      generateNavigationController(with: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
      generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
    ]
  }
  
  fileprivate func setupPlayerDetailsView() {
    print("setupPlayerDetailsView")
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    playerDetailsView.backgroundColor = .red
        
    view.insertSubview(playerDetailsView, belowSubview: tabBar)
    
    // Enables AutoLayout
    playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
    
    // Set playerDetailsView from the very bottom by setting constant = view.frame.height
    maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
    maximizedTopAnchorConstraint.isActive = true
    
    minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//    minimizedTopAnchorConstraint.isActive = true
    
    playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
