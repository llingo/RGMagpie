//
//  RGMagpieError.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import Foundation

public enum RGMagpieError: Error {
  case unknownError
  case notModifiedError
  case badRequestError
  case unAuthorizedError
  case notFoundError
  case internalServerError
  case serviceUnavailableError
  case invalidateResponseError
  case errorIsOccurred(_ error: String)

  case invalidateURLError
  case invalidateImageError
}
