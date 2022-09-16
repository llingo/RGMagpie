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

    guard let url = URL(string: urlString) else {
      completion?(.failure(.invalidateURLError))
      return nil
    }

    if let cachedImageData = ImageCache.default.retrieve(forKey: url) {
      base.image = UIImage(data: cachedImageData)
      return nil
    }

    let task = ImageDownloader.default.downloadImage(with: url) { result in
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

    mutatingSelf.imageTask = task
    return task
  }
}
