//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by David on 2020/12/1.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
  // MARK: - Instance Properties
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      
      guard let url = URL(string: episode.imageUrl ?? "") else { return }
      episodeImageView.sd_setImage(with: url)
    }
  }
     
  // MARK: - IBOutlets
  @IBOutlet weak var authorLabel: UILabel!
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.numberOfLines = 2
    }
  }
  @IBOutlet weak var episodeImageView: UIImageView!
  
  @IBOutlet weak var playPauseButton: UIButton! {
    didSet {
      playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
        
  // MARK: - Selector Methods
  @objc func handlePlayPause() {
    print("handlePlayPause")
  }
  
  // MARK: - IBActions
  @IBAction func handleDismiss(_ sender: Any) {
    self.removeFromSuperview()
  }
}
