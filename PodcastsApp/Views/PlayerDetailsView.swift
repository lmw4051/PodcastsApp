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
      miniTitleLabel.text = episode.title
      authorLabel.text = episode.author

      playEpisode()
      
      guard let url = URL(string: episode.imageUrl ?? "") else { return }
      episodeImageView.sd_setImage(with: url)
      miniEpisodeImageView.sd_setImage(with: url)
    }
  }
  
  let player: AVPlayer = {
    let avPlayer = AVPlayer()
    avPlayer.automaticallyWaitsToMinimizeStalling = false
    return avPlayer
  }()
  
  fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  
  var panGesture: UIPanGestureRecognizer!
  
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
  
  @IBOutlet weak var miniPlayerView: UIView!
  @IBOutlet weak var maximizedStackView: UIStackView!
  
  @IBOutlet weak var miniEpisodeImageView: UIImageView!
  @IBOutlet weak var miniTitleLabel: UILabel!
  
  @IBOutlet weak var miniPlayPauseButton: UIButton! {
    didSet {
      miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
      miniPlayPauseButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    }
  }
  @IBOutlet weak var miniFastForwardButton: UIButton! {
    didSet {
      miniFastForwardButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
      miniFastForwardButton.addTarget(self, action: #selector(handleFastForward), for: .touchUpInside)
    }
  }
  
  // MARK: - IBAction Methods
  @IBAction func handleDismiss(_ sender: Any) {
    UIApplication.mainTabBarController()?.minimizePlayerDetails()
  }
  
  @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
    let percentage = currentTimeSlider.value
    guard let duration = player.currentItem?.duration else { return }
    let durationInSeconds = CMTimeGetSeconds(duration)
    let seekTimeInSeconds = Float64(percentage) * durationInSeconds
    let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
    player.seek(to: seekTime)
  }
  
  @IBAction func handleFastForward(_ sender: Any) {
    seekToCurrentTime(delta: 15)
  }
  
  @IBAction func handleRewind(_ sender: Any) {
    seekToCurrentTime(delta: -15)
  }
  
  @IBAction func handleVolumeChange(_ sender: UISlider) {
    player.volume = sender.value
  }
  
  
  // MARK: - View Life Cycle
  fileprivate func setupGestures() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    miniPlayerView.addGestureRecognizer(panGesture)
    
    maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupGestures()
    
    observePlatyerCurrentTime()
    
    let time = CMTimeMake(value: 1, timescale: 3)
    let times = [NSValue(time: time)]
        
    player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
      print("Episode started playing")
      self?.enlargeEpisodeImageView()
    }
  }
  
  static func initFromNib() -> PlayerDetailsView {
    return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
  }
  
  deinit {
    print("PlayerDetailsView memory being reclaimed")
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
        
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      self?.currentTimeLabel.text = time.toDisplayString()
      let durationTime = self?.player.currentItem?.duration
      self?.durationLabel.text = durationTime?.toDisplayString()
      
      self?.updateCurrentTimeSlier()
    }
  }
  
  fileprivate func updateCurrentTimeSlier() {
    let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
    let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    let percentage = currentTimeSeconds / durationSeconds
    
    self.currentTimeSlider.value = Float(percentage)
  }
  
  fileprivate func seekToCurrentTime(delta: Int64) {
    let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
    let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
    player.seek(to: seekTime)
  }
  
  // MARK: - Selector Methods
  @objc func handlePlayPause() {
    print("Trying to play and pause")
    if player.timeControlStatus == .paused {
      player.play()
      playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      enlargeEpisodeImageView()
    } else {
      player.pause()
      playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      shrinkEpisodeImageView()
    }
  }
  
  @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
    print("handleDismissalPan")
    
    if gesture.state == .changed {
      let translation = gesture.translation(in: superview)
      maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
    } else if gesture.state == .ended {
      let translation = gesture.translation(in: superview)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.maximizedStackView.transform = .identity
        
        if translation.y > 100 {
          UIApplication.mainTabBarController()?.minimizePlayerDetails()
        }
      })
    }
  }
}
