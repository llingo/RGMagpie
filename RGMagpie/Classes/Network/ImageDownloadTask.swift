//
//  ImageDownloadTask.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import Foundation

public protocol ImageDownloadTask {
  func suspend()
  func cancel()
}

// MARK: - Extension

extension URLSessionTask: ImageDownloadTask {}
