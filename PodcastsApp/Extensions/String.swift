//
//  String.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

extension String {
  func toSecureHTTPS() -> String {
    return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
  }
}
