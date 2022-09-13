//
//  RGMagpie.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//  Copyright © 2022 RGMagpie. All rights reserved.
//

import UIKit

public struct RGMagpie<Base> {
  public let base: Base

  public init(_ base: Base) {
    self.base = base
  }
}

public protocol RGMagpieCompatible: AnyObject {}

extension RGMagpieCompatible {
  public var mp: RGMagpie<Self> {
    get { RGMagpie(self) }
  }
}

// MARK: - Extension

extension UIImageView: RGMagpieCompatible {}

