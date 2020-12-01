//
//  CMTime.swift
//  PodcastsApp
//
//  Created by David on 2020/12/1.
//  Copyright © 2020 David. All rights reserved.
//

import AVKit

extension CMTime {
  func toDisplayString() -> String {
    let totalSeconds = Int(CMTimeGetSeconds(self))
    let seconds = totalSeconds % 60
    let minutes = totalSeconds / 60
    let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
    return timeFormatString
  }
}
