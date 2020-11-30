//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by David on 2020/12/1.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      
      guard let url = URL(string: episode.imageUrl ?? "") else { return }
      episodeImageView.sd_setImage(with: url)
    }
  }
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var episodeImageView: UIImageView!
  
  @IBAction func handleDismiss(_ sender: Any) {
    self.removeFromSuperview()
  }
}
