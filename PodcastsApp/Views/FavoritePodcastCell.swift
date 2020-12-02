//
//  FavoritePodcastCell.swift
//  PodcastsApp
//
//  Created by David on 2020/12/2.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
  // MARK: - Instance Properties
  let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
  let nameLabel = UILabel()
  let artistNameLabel = UILabel()
  
  // MARK: - View Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    stylizeUI()
    setupViews()
  }
  
  fileprivate func stylizeUI() {
    nameLabel.text = "Podcast Name"
    nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    
    artistNameLabel.text = "Artist Name"
    artistNameLabel.font = .systemFont(ofSize: 14)
    artistNameLabel.textColor = .lightGray
  }
  
  fileprivate func setupViews() {
    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true        
    
    let stackView = UIStackView(arrangedSubviews: [
      imageView, nameLabel, artistNameLabel
    ])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
