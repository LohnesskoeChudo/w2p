//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 23.03.2021.
//

import UIKit

protocol PImageLoader {
    func load(with request: URLRequest, completion: @escaping (UIImage?, Error?) -> Void)
}

class ImageLoader: PImageLoader {
    
    private var dataLoader = Resolver.shared.container.resolve(PDataLoader.self)!
    
    func load(with request: URLRequest, completion: @escaping (UIImage?, Error?) -> Void) {
        dataLoader.load(with: request) {
            data, error in
            if let data = data {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let image = UIImage(data: data) {
                        completion(image, nil)
                    } else {
                        completion(nil, ImageLoaderError.cantDecodeImage)
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

enum ImageLoaderError: Error {
    case cantDecodeImage
}
