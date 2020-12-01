//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Brian Voong on 2/28/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
  // MARK: - Instance Properties
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      miniTitleLabel.text = episode.title
      authorLabel.text = episode.author
      
      setupNowPlayingInfo()
      
      playEpisode()
      
      guard let url = URL(string: episode.imageUrl ?? "") else { return }
      episodeImageView.sd_setImage(with: url)
            
      miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
        // Lock Screen Artwork Setup
        guard let image = image else { return }

        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
          return image
        }
        nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
      }
    }
  }
  
  let player: AVPlayer = {
    let avPlayer = AVPlayer()
    avPlayer.automaticallyWaitsToMinimizeStalling = false
    return avPlayer
  }()
  
  fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  
  var panGesture: UIPanGestureRecognizer!
  
  var playlistEpisodes = [Episode]()
  
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
    
    setupRemoteControl()
    
    setupAudioSession()
    
    setupGestures()
    
    observePlayerCurrentTime()
    
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
  
  fileprivate func observePlayerCurrentTime() {
    let interval = CMTimeMake(value: 1, timescale: 2)
    
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      self?.currentTimeLabel.text = time.toDisplayString()
      let durationTime = self?.player.currentItem?.duration
      self?.durationLabel.text = durationTime?.toDisplayString()
      
      self?.setupLockScreenCurrentTime()
      
      self?.updateCurrentTimeSlider()
    }
  }
  
  fileprivate func setupLockScreenCurrentTime() {
    var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
    
    guard let currentItem = player.currentItem else { return }
    let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
    let elapsedTime = CMTimeGetSeconds(player.currentTime())
        
    nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
  
  fileprivate func updateCurrentTimeSlider() {
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
  
  fileprivate func setupAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch let sessionErr {
      print("Failed to activate session:", sessionErr)
    }
  }
  
  fileprivate func setupRemoteControl() {
    UIApplication.shared.beginReceivingRemoteControlEvents()
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
    MPRemoteCommandCenter.shared().playCommand.isEnabled = true
    MPRemoteCommandCenter.shared().playCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
      self.player.play()
      self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      return .success
    }
    
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
      self.player.pause()
      self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      return .success
    }
    
    commandCenter.togglePlayPauseCommand.isEnabled = true
    commandCenter.togglePlayPauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
      self.handlePlayPause()
      return .success
    }
    
    commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
    commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
  }
  
  fileprivate func setupNowPlayingInfo() {
    var nowPlayingInfo = [String: Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
    nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
  
  // Must return MPRemoteCommandHandlerStatus in iOS 13
  @objc fileprivate func handleNextTrack() -> MPRemoteCommandHandlerStatus {
    if playlistEpisodes.count == 0 {
      return .success
    }
    
    let currentEpisodeIndex = playlistEpisodes.index { episode -> Bool in
      return self.episode.title == episode.title && self.episode.author == episode.author
    }
    
    guard let index = currentEpisodeIndex else {
      return .success
    }
    
    let nextEpisode: Episode
    
    if index == playlistEpisodes.count - 1 {
      nextEpisode = playlistEpisodes[0]
    } else {
      nextEpisode = playlistEpisodes[index + 1]
    }
    
    self.episode = nextEpisode
    
    return .success
  }
  
  @objc fileprivate func handlePrevTrack() -> MPRemoteCommandHandlerStatus {
    // 1. Check if playlistEpidoes.count == 0 then return
    // 2. find out current episode index
    // 3. if episode index is 0, wrap to end of list somehow...
    // otherwise play episode index - 1
    
    if playlistEpisodes.isEmpty {
      return .success
    }
    
    let currentEpisodeIndex = playlistEpisodes.index { episode -> Bool in
      return self.episode.title == episode.title && self.episode.author == episode.author
    }
    
    guard let index = currentEpisodeIndex else { return .success }
    
    let prevEpisode: Episode
    
    if index == 0 {
      let count = playlistEpisodes.count
      prevEpisode = playlistEpisodes[count - 1]
    } else {
      prevEpisode = playlistEpisodes[index - 1]
    }
    
    self.episode = prevEpisode
    
    return .success
  }
}
