//
//  ImageDownloader.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import Foundation

final class ImageDownloader {
  static let `default` = ImageDownloader(name: "default")

  private let sessionConfiguration = URLSessionConfiguration.ephemeral
  private let session: URLSession

  let name: String

  init(name: String) {
    self.name = name

    session = URLSession(
      configuration: sessionConfiguration,
      delegate: nil,
      delegateQueue: nil
    )
  }

  func download(
    with url: URL,
    completion: @escaping (Result<Data, RGMagpieError>) -> Void
  ) -> ImageDownloadTask {
    let task = session.dataTask(with: url) { data, response, error in
      guard error == nil, let data = data else {
        completion(.failure(.errorIsOccurred(error.debugDescription)))
        return
      }
      guard let response = response as? HTTPURLResponse else {
        completion(.failure(.invalidateResponseError))
        return
      }

      switch response.statusCode {
      case 200..<300: completion(.success(data))
      case 400: completion(.failure(.badRequestError))
      case 401: completion(.failure(.unAuthorizedError))
      case 404: completion(.failure(.notFoundError))
      case 500: completion(.failure(.internalServerError))
      case 503: completion(.failure(.serviceUnavailableError))
      default: completion(.failure(.unknownError))
      }
    }
    task.resume()
    return task
  }
}
