//
//  UIImageView+Extensions.swift
//  NewsApp
//
//  Created by Arsenii Kovalenko on 28.09.2022.
//

import UIKit

extension UIImageView {
    
    func load(url: URL, cache: URLCache = .shared) {
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
        
        dataTask.resume()
    }
}
