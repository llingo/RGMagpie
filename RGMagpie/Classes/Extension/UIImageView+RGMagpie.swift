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
    placeholder: UIImage? = nil,
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
     # ETag 확인
     - 304 Not-Modified라면 Cache 로직 시작
     - 200 OK로 새로운 ETag을 받으면 Memory, Disk 캐시에 저장

     setImage(with:placeholder:completion:)
        1) 304 Not-Modified ---> Check memory / disk cache -> if image == nil, API Request
        2) 200 OK: New ETag ---> Save to memory / disk cache
    */

    let etag = UserDefaults.standard.string(forKey: "RGMagpie-Etag-\(url.path)")

    return ImageDownloader.default.downloadImage(with: url, etag: etag) { result in
      switch result {
      case .success(let item):
        if let image = UIImage(data: item.imageData) {
          UserDefaults.standard.set(item.etag, forKey: "RGMagpie-Etag-\(url.path)")
          ImageCache.default.store(item.imageData, forKey: url)

          loadImageOnMainScheduler(image: image)
          completion?(.success(image))

        } else {
          loadImageOnMainScheduler(image: placeholder ?? UIImage())
          completion?(.failure(.invalidateImageError))
        }

      case .failure(let error):
        if case .notModifiedError = error, let cachedData = ImageCache.default.retrieve(forKey: url) {
          loadImageOnMainScheduler(image: UIImage(data: cachedData))

        } else {
          loadImageOnMainScheduler(image: placeholder ?? UIImage())
        }
        completion?(.failure(error))
      }
    }
  }

  private func loadImageOnMainScheduler(image: UIImage?) {
    DispatchQueue.main.async { [weak view = base as UIImageView] in
      view?.image = image
    }
  }
}
