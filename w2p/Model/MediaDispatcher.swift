//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import Foundation
import UIKit

protocol PMediaDispatcher {
    func fetchPreparedToSetStaticMedia(with media: MediaDownloadable, targetWidth: CGFloat, sizeKey: GameImageSizeKey, completion: ((UIImage?, Error?) -> Void)?)
    func fetchStaticMedia(with media: MediaDownloadable,  sizeKey: GameImageSizeKey, completion: ((Data?, Error?) -> Void)?)
}

final class MediaDispatcher: PMediaDispatcher {
    private let dataLoader = Resolver.shared.container.resolve(PDataLoader.self)!
    private let jsonLoader = Resolver.shared.container.resolve(PJsonLoader.self)!
    private let cacheManager = Resolver.shared.container.resolve(PCacheManager.self)!
    private let requestFormer = Resolver.shared.container.resolve(PRequestFormer.self)!
    private var cache: Bool
    
    init(cache: Bool) {
        self.cache = cache
    }
    
    func fetchPreparedToSetStaticMedia(with media: MediaDownloadable, targetWidth: CGFloat, sizeKey: GameImageSizeKey, completion: ((UIImage?, Error?) -> Void)? = nil) {
        fetchStaticMedia(with: media, sizeKey: sizeKey) { data, error in
            if let data = data {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let image = UIImage(data: data) {
                        let resizedImage = ImageResizer.resizeImageToFit(width: targetWidth, image: image)
                        completion?(resizedImage, nil)
                    } else {
                        completion?(nil, ResizingError.canNotResizeImage)
                    }
                }
            } else {
                completion?(nil, error)
            }
        }
    }
    
    func fetchStaticMedia(with media: MediaDownloadable,  sizeKey: GameImageSizeKey, completion: ((Data?, Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.cacheManager.loadStaticMedia(with: media, sizeKey: sizeKey){
                data in
                if let data = data {
                    completion?(data, nil)
                } else {
                    if self.cache {
                        self.bringStaticMediaToCache(media: media, sizeKey: sizeKey, completion: completion)
                    } else {
                        self.loadStaticMediaFromInet(media: media, sizeKey: sizeKey, completion: completion)
                    }
                }
            }
        }
    }
    
    private func bringStaticMediaToCache(media: MediaDownloadable, sizeKey: GameImageSizeKey, completion: ((Data?, FetchingError?) -> Void)? = nil) {
        self.loadStaticMediaFromInet(media: media, sizeKey: sizeKey) {
            data, error in
            if let data = data {
                self.cacheManager.saveStaticMedia(data: data, sizeKey: sizeKey, media: media)
                completion?(data, nil)
            } else {
                completion?(nil, error)
            }
        }
    }
    
    private func loadStaticMediaFromInet(media: MediaDownloadable, sizeKey: GameImageSizeKey, completion: ((Data?, FetchingError?) -> Void)? = nil) {
        guard let staticMediaRequest = self.requestFormer.formRequestForMediaStaticContent(for: media, sizeKey: sizeKey) else {
            completion?(nil, .canNotFormRequest)
            return
        }
        dataLoader.load(with: staticMediaRequest) {
            data, error in
            if let data = data {
                completion?(data, nil)
            } else {
                completion?(nil, .connectionError)
            }
        }
    }
    
    enum ResizingError: Error {
        case canNotResizeImage
    }
}

enum FetchingError: Error {
    case connectionError
    case canNotFormRequest
    case noCoverId
    case noItemInDb
}
