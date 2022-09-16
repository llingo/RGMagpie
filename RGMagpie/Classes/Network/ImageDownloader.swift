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

  private func download(
    with request: URLRequest,
    completion: @escaping (Result<ImageItem, RGMagpieError>) -> Void
  ) -> ImageDownloadTask {
    let task = session.dataTask(with: request) { data, response, error in
      guard error == nil, let data = data else {
        completion(.failure(.errorIsOccurred(error.debugDescription)))
        return
      }
      guard let response = response as? HTTPURLResponse else {
        completion(.failure(.invalidateResponseError))
        return
      }

      switch response.statusCode {
      case 200..<300:
        let etag = response.allHeaderFields["Etag"] as? String
        let item = ImageItem(imageData: data, etag: etag)
        completion(.success(item))

      case 304: completion(.failure(.notModifiedError))
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

  func downloadImage(
    with url: URL,
    etag: String? = nil,
    completion: @escaping (Result<ImageItem, RGMagpieError>) -> Void
  ) -> ImageDownloadTask {
    var request = URLRequest(url: url)

    if let etag = etag {
      request.addValue(etag, forHTTPHeaderField: "If-None-Match")
    }

    return download(with: request, completion: completion)
  }
}
