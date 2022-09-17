//
//  ImageCache.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/14.
//

import Foundation

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

  convenience init(name: String) {
    let memoryStorage = MemoryStorage(name: "\(name.capitalized)ImageCache", policy: .init())
    let diskStorage = DiskStorage(name: "\(name.capitalized)ImageCache", policy: .init())
    self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
  }

  func store(_ imageData: Data, forKey imageURL: URL) {
    memoryStorage.setObject(imageData, forKey: imageURL)
    diskStorage.setObject(imageData, forKey: imageURL)
  }

  func retrieve(forKey imageURL: URL) -> Data? {
    if let memoryData = memoryStorage.object(forKey: imageURL) {
      return memoryData
    }

    if let diskData = diskStorage.object(forKey: imageURL) {
      memoryStorage.setObject(diskData, forKey: imageURL)
      return diskData
    }
    return nil
  }
}
