//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by David on 2020/12/1.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
  // MARK: - Instance Properties
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      
      playEpisode()
      
      guard let url = URL(string: episode.imageUrl ?? "") else { return }
      episodeImageView.sd_setImage(with: url)
    }
  }
  
  let player: AVPlayer = {
    let avPlayer = AVPlayer()
    avPlayer.automaticallyWaitsToMinimizeStalling = false
    return avPlayer
  }()
  
  // MARK: - Helper Methods
  fileprivate func playEpisode() {
    print("playEpisode:", episode.streamUrl)
    
    guard let url = URL(string: episode.streamUrl) else { return }
    let playerItem = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: playerItem)
    player.play()
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
    if player.timeControlStatus == .paused {
      player.play()
      playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    } else {
      player.pause()
      playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
  }
  
  // MARK: - IBActions
  @IBAction func handleDismiss(_ sender: Any) {
    self.removeFromSuperview()
  }
}
