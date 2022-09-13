//
//  ImageCache.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/14.
//

import UIKit

final class ImageCache {
  static let `default` = ImageCache(name: "default")

  private let memoryStorage: MemoryStorage
  private let diskStorage: DiskStorage

  init(
    memoryStorage: MemoryStorage,
    diskStorage: DiskStorage
  ) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }

  convenience init(name: String, memoryPolicy: String? = nil, diskPolicy: String? = nil) {
    let memoryStorage = MemoryStorage(name: name, policy: .init())
    let diskStorage = DiskStorage(name: "\(name)Image", policy: .init())
    self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
  }

  func store(_ image: UIImage, forKey imageURL: URL) {
    if let imageData = image.jpegData(compressionQuality: 0.5) {
      memoryStorage.setObject(imageData, forKey: imageURL)
      diskStorage.setObject(imageData, forKey: imageURL)
    }
  }

  func retrieve(forKey imageURL: URL) -> UIImage? {
    if let memoryData = memoryStorage.object(forKey: imageURL) {
      return UIImage(data: memoryData)
    }

    if let diskData = diskStorage.object(forKey: imageURL) {
      memoryStorage.setObject(diskData, forKey: imageURL)
      return UIImage(data: diskData)
    }
    return nil
  }
}
