//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Brian Voong on 2/28/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
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
  
  fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  
  // MARK: - IBOutlets
  @IBOutlet weak var currentTimeSlider: UISlider!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var currentTimeLabel: UILabel!
  
  @IBOutlet weak var episodeImageView: UIImageView! {
    didSet {
      episodeImageView.layer.cornerRadius = 5
      episodeImageView.clipsToBounds = true
      episodeImageView.transform = shrunkenTransform
    }
  }
  
  @IBOutlet weak var playPauseButton: UIButton! {
    didSet {
      playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
  
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.numberOfLines = 2
    }
  }
  
  // MARK: - IBActions
  @IBAction func handleDismiss(_ sender: Any) {
    self.removeFromSuperview()
  }
  
  // MARK: - View Life Cycle
  override func awakeFromNib() {
    super.awakeFromNib()
    
    observePlatyerCurrentTime()
    
    let time = CMTimeMake(value: 1, timescale: 3)
    let times = [NSValue(time: time)]
    player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
      print("Episode started playing")
      self.enlargeEpisodeImageView()
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func playEpisode() {
    print("Trying to play episode at url:", episode.streamUrl)
    
    guard let url = URL(string: episode.streamUrl) else { return }
    let playerItem = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: playerItem)
    player.play()
  }
  
  fileprivate func enlargeEpisodeImageView() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.episodeImageView.transform = .identity
    })
  }
  
  fileprivate func shrinkEpisodeImageView() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {      
      self.episodeImageView.transform = self.shrunkenTransform
    })
  }
  
  fileprivate func observePlatyerCurrentTime() {
    let interval = CMTimeMake(value: 1, timescale: 2)
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
      self.currentTimeLabel.text = time.toDisplayString()
      let durationTime = self.player.currentItem?.duration
      self.durationLabel.text = durationTime?.toDisplayString()
      
      self.updateCurrentTimeSlier()
    }
  }
  
  fileprivate func updateCurrentTimeSlier() {
    let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
    let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    let percentage = currentTimeSeconds / durationSeconds
    
    self.currentTimeSlider.value = Float(percentage)
  }
  
  // MARK: - Selector Methods
  @objc func handlePlayPause() {
    print("Trying to play and pause")
    if player.timeControlStatus == .paused {
      player.play()
      playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      enlargeEpisodeImageView()
    } else {
      player.pause()
      playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      shrinkEpisodeImageView()
    }
  }
}
