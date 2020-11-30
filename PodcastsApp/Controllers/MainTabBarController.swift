//
//  MainTabBarController.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    UINavigationBar.appearance().prefersLargeTitles = true
    tabBar.tintColor = .purple
    
    setupViewControllers()
  }
  
  // MARK: - Setup Methods
  func setupViewControllers() {
    viewControllers = [
      generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
      generateNavigationController(with: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
      generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
    ]
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
