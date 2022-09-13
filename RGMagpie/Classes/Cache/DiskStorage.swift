//
//  DiskStorage.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import Foundation

struct DiskCachePolicy {
  var maximumDiskSizeLimit: Int = .zero
}

final class DiskStorage: Storagable {
  private let storage = FileManager.default

  private var maximumDiskSizeLimit: Int
  private var currentDiskSize: Int = .zero

  let name: String

  init(name: String, policy: DiskCachePolicy) {
    self.name = name
    maximumDiskSizeLimit = policy.maximumDiskSizeLimit
  }

  func setObject(_ object: Data, forKey imageURL: URL) {
    guard currentDiskSize + object.count >= maximumDiskSizeLimit else { return }
    guard let imagePath = generateImagePath(with: imageURL) else { return }

    do {
      try object.write(to: imagePath)
      currentDiskSize += object.count

    } catch {
      debugPrint(error.localizedDescription)
    }
  }

  func object(forKey imageURL: URL) -> Data? {
    guard let imagePath = generateImagePath(with: imageURL) else { return nil }

    do {
      return try Data(contentsOf: imagePath)

    } catch {
      debugPrint(error.localizedDescription)
      return nil
    }
  }

  func removeObject(forKey imageURL: URL) {
    guard let imagePath = generateImagePath(with: imageURL) else { return }

    do {
      let fileAttributes = try storage.attributesOfItem(atPath: imagePath.path)

      if let fileSize = fileAttributes[.size] as? Int {
        try storage.removeItem(at: imagePath)
        currentDiskSize += fileSize
      }

    } catch {
      debugPrint(error.localizedDescription)
      return
    }
  }

  private func generateImagePath(with imageURL: URL) -> URL? {
    guard let path = storage.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
    let directoryPath = path.appendingPathComponent(name)

    let cacheKey = imageURL.pathComponents.joined(separator: "-")
    let imagePath = directoryPath.appendingPathComponent(cacheKey)

    if storage.fileExists(atPath: directoryPath.path) == false {
      try? storage.createDirectory(at: directoryPath, withIntermediateDirectories: false)
    }
    return imagePath
  }
}
