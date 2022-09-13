//
//  SampleTableViewCell.swift
//  RGMagpie_Example
//
//  Created by Ringo on 2022/09/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

import RGMagpie

final class SampleTableViewCell: UITableViewCell {
  static let identifier = "SampleTableViewCell"

  private let sampleImageView = UIImageView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(sampleImageView)
    sampleImageView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      sampleImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      sampleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      sampleImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      sampleImageView.widthAnchor.constraint(equalTo: sampleImageView.heightAnchor, multiplier: 0.8)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setup() {
    /// RGMagpie를 사용하여 비동기 이미지 받아오기 :)
    sampleImageView.mp.setImage(with: "https://picsum.photos/seed/picsum/200/300")
  }
}
