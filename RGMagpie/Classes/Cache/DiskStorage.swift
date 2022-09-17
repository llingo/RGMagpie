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
  private let lock = NSLock()

  /// if maximumDiskSizeLimit is zero, no limit
  private(set) var maximumDiskSizeLimit: Int
  private(set) var currentDiskSize: Int = .zero

  let name: String

  init(name: String, policy: DiskCachePolicy) {
    self.name = name
    maximumDiskSizeLimit = policy.maximumDiskSizeLimit
  }

  func setObject(_ object: Data, forKey imageURL: URL) {
    lock.lock()
    defer {
      calculateTotalFileSize()
      lock.unlock()
    }

    guard maximumDiskSizeLimit == .zero || currentDiskSize + object.count <= maximumDiskSizeLimit else { return }
    guard let imagePath = generateImagePath(with: imageURL) else { return }

    do {
      try object.write(to: imagePath)

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
    lock.lock()
    defer {
      calculateTotalFileSize()
      lock.unlock()
    }

    guard let imagePath = generateImagePath(with: imageURL) else { return }

    do {
      try storage.removeItem(at: imagePath)

    } catch {
      debugPrint(error.localizedDescription)
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

  private func calculateTotalFileSize() {
    guard let cacheDirectoryURL = storage.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
    let diskCacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(name)

    if storage.fileExists(atPath: diskCacheDirectoryURL.path) == false {
      currentDiskSize = .zero
      return
    }

    var totalFileSize: Int = .zero

    let fileNames = try? storage.contentsOfDirectory(atPath: diskCacheDirectoryURL.path)
    fileNames?.forEach { fileName in
      let filePath = diskCacheDirectoryURL.path.appending("/\(fileName)")
      let fileAttributes = try? storage.attributesOfItem(atPath: filePath)
      let fileSize = fileAttributes?[.size] as? Int ?? .zero
      totalFileSize += fileSize
    }

    currentDiskSize = totalFileSize
  }
}
