//
//  Storagable.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import Foundation

protocol Storagable {
  func setObject(_ object: Data, forKey imageURL: URL)
  func object(forKey imageURL: URL) -> Data?
  func removeObject(forKey imageURL: URL)
}
