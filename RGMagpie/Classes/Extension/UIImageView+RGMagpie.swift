//
//  UIImageView+RGMagpie.swift
//  RGMagpie
//
//  Created by Ringo on 2022/09/13.
//

import UIKit

private var imageTaskKey: Void?

extension RGMagpie where Base: UIImageView {
  private var imageTask: ImageDownloadTask? {
    get { objc_getAssociatedObject(base, &imageTaskKey) as? ImageDownloadTask }
    set { objc_setAssociatedObject(base, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  @discardableResult
  public func setImage(
    with urlString: String,
    placeholder: UIImage? = UIImage(),
    completion: ((Result<UIImage, RGMagpieError>) -> Void)? = nil
  ) -> ImageDownloadTask? {
    var mutatingSelf = self

    if let task = mutatingSelf.imageTask {
      mutatingSelf.imageTask = nil
      task.suspend()
      task.cancel()
    }

    let task = loadImage(with: urlString, placeholder: placeholder, completion: completion)
    mutatingSelf.imageTask = task

    return task
  }

  private func loadImage(
    with urlString: String,
    placeholder: UIImage?,
    completion: ((Result<UIImage, RGMagpieError>) -> Void)?
  ) -> ImageDownloadTask? {
    guard let url = URL(string: urlString) else {
      completion?(.failure(.invalidateURLError))
      return nil
    }

    /*
     1. ETag 확인
     - 1-1. 304 Not-Modified라면 Cache 로직 시작
     - 1-2. 200 OK로 새로운 ETag을 받으면 Memory, Disk 캐시에 저장

     setImage(with:placeholder:completion:)
        |---304 Not-Modified---> Check memory / disk cache -> API Request
        |
        |---200 OK ETag: abc---> Save to memory / disk cache
    */

    let etag = UserDefaults.standard.string(forKey: url.path)

    return ImageDownloader.default.downloadImage(with: url, etag: etag) { result in
      switch result {
      case .success(let item):
        if let image = UIImage(data: item.imageData) {
          UserDefaults.standard.set(item.etag, forKey: url.path)
          ImageCache.default.store(item.imageData, forKey: url)

          DispatchQueue.main.async { [weak view = base as UIImageView] in
            view?.image = image
            completion?(.success(image))
          }
          return
        }
        completion?(.failure(.invalidateImageError))

      case .failure(let error):
        if case .notModifiedError = error {
          if let cachedImageData = ImageCache.default.retrieve(forKey: url) {
            DispatchQueue.main.async { [weak view = base as UIImageView] in
              view?.image = UIImage(data: cachedImageData)
            }
          }
          completion?(.failure(error))
          return
        }
        completion?(.failure(error))
      }

      DispatchQueue.main.async { [weak view = base as UIImageView] in
        view?.image = placeholder
      }
    }

    // MARK: - Legacy
    /*
    if let cachedImageData = ImageCache.default.retrieve(forKey: url) {
      base.image = UIImage(data: cachedImageData)
      return nil
    }

    return ImageDownloader.default.downloadImage(with: url) { result in
      switch result {
      case .success(let item):
        if let image = UIImage(data: item.imageData) {
          ImageCache.default.store(item.imageData, forKey: url)

          DispatchQueue.main.async { [weak view = base as UIImageView] in
            view?.image = image
            completion?(.success(image))
          }
          return
        }
        completion?(.failure(.invalidateImageError))

      case .failure(let error):
        completion?(.failure(error))
      }

      DispatchQueue.main.async { [weak view = base as UIImageView] in
        view?.image = placeholder
      }
    }
   */
  }
}
