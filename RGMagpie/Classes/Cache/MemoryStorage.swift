//
//  MemoryStorage.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import Foundation

struct MemoryCachePolicy {
  var maximumMemoryCountLimit: Int = .zero
  var maximumMemorySizeLimit: Int = .zero
  var evictsObjectsWithDiscardedContent: Bool = true
}

final class MemoryStorage {
  private let cache = NSCache<NSString, NSData>()
  private let lock = NSLock()

  init(name: String, policy: MemoryCachePolicy) {
    cache.name = name
    cache.countLimit = policy.maximumMemoryCountLimit
    cache.totalCostLimit = policy.maximumMemorySizeLimit
    cache.evictsObjectsWithDiscardedContent = policy.evictsObjectsWithDiscardedContent
  }

  func setObject(_ object: Data, forKey imageURL: URL) {
    lock.lock()
    defer { lock.unlock() }

    let cacheKey = NSString(string: imageURL.path)
    let objectSize = object.count
    cache.setObject(object as NSData, forKey: cacheKey, cost: objectSize)
  }

  func object(forKey imageURL: URL) -> Data? {
    let cacheKey = NSString(string: imageURL.path)
    return cache.object(forKey: cacheKey) as Data?
  }

  func removeObject(forKey imageURL: URL) {
    lock.lock()
    defer { lock.unlock() }

    let cacheKey = NSString(string: imageURL.path)
    cache.removeObject(forKey: cacheKey)
  }
}
