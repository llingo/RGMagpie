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
    setLayout()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setLayout()
  }

  func setup() {
    // RGMagpie를 사용하여 비동기 이미지 받아오기 :)
    sampleImageView.mp.setImage(with: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/%22_The_Calutron_Girls%22_Y-12_Oak_Ridge_1944_Large_Format_%2832093954911%29_%282%29.jpg/1280px-%22_The_Calutron_Girls%22_Y-12_Oak_Ridge_1944_Large_Format_%2832093954911%29_%282%29.jpg")
  }

  private func setLayout() {
    contentView.addSubview(sampleImageView)
    sampleImageView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      sampleImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      sampleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      sampleImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      sampleImageView.widthAnchor.constraint(equalTo: sampleImageView.heightAnchor, multiplier: 0.8)
    ])
  }
}
