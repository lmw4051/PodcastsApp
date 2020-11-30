//
//  EpisodeCell.swift
//  PodcastsApp
//
//  Created by David on 2020/11/30.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
  // MARK: - Instance Properties
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      descriptionLabel.text = episode.description
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
      
      let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
      episodeImageView.sd_setImage(with: url)
    }
  }
  // MARK: - View Life Cycle
  @IBOutlet weak var episodeImageView: UIImageView!
  @IBOutlet weak var pubDateLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.numberOfLines = 2
    }
  }
  
  @IBOutlet weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.numberOfLines = 2
    }
  }
}
