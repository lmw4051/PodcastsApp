//
//  UIApplication.swift
//  PodcastsApp
//
//  Created by David on 2020/12/1.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

extension UIApplication {
  static func mainTabBarController() -> MainTabBarController? {
    return shared.keyWindow?.rootViewController as? MainTabBarController
  }
}
