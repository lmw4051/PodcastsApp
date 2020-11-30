//
//  PodcastCell.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class PodcastCell: UITableViewCell {
  
  @IBOutlet weak var podcastImageView: UIImageView!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var episodeCountLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  
  var podcast: Podcast! {
    didSet {
      trackNameLabel.text = podcast.trackName
      artistNameLabel.text = podcast.artistName
    }
  }
}
