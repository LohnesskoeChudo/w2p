//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import Foundation
import UIKit

class MediaDispatcher {
    
    private let dataLoader = DataLoader()
    private let jsonLoader = JsonLoader()

    func fetchPreparedToSetStaticMedia(with media: MediaDownloadable, targetWidth: CGFloat, sizeKey: GameImageSizeKey, cache: Bool = true, completion: ((UIImage?, Error?) -> Void)? = nil) {
        
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
    
    enum ResizingError: Error {
        case canNotResizeImage
    }
    
    func getTotalAmountOfGames(completion: ((Int) -> Void)? = nil){
        let secondsSinceLastSaving = CacheManager.shared.secondsSinceLastSavingTotalApiGamesCount
        let oneDayInSeconds = 86400
        if let totalAmount = CacheManager.shared.getTotalApiGamesCount(), let secondsSinceLastSaving = secondsSinceLastSaving, secondsSinceLastSaving < oneDayInSeconds {
            completion?(totalAmount)
        } else {
            loadGameApiTotalCount() {
                count in
                if let count = count{
                    CacheManager.shared.saveTotalApiGamesCount(value: count)
                    completion?(count)
                } else {
                    let defaultApiValue = 138000
                    completion?(defaultApiValue)
                }
            }
        }
    }
    
    private func loadGameApiTotalCount(completion: ((Int?)->Void)? = nil) {
        let request = RequestFormer.shared.formRequestForTotalGameCount()
        jsonLoader.load(request: request) {
            (response: [String: Int]?, error: Error?) in
            if let response = response {
                if let count = response["count"] {
                    completion?(count)
                } else {
                    completion?(nil)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    func fetchStaticMedia(with media: MediaDownloadable,  sizeKey: GameImageSizeKey, cache: Bool = true, completion: ((Data?, Error?) -> Void)? = nil) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            CacheManager.shared.loadStaticMedia(with: media, sizeKey: sizeKey){
                data in
                if let data = data {
                    completion?(data, nil)
                } else {
                    if cache {
                        self.bringStaticMediaToCache(media: media, sizeKey: sizeKey, completion: completion)
                    } else {
                        self.loadStaticMediaFromInet(media: media, sizeKey: sizeKey, completion: completion)
                    }
                }
            }
        }
    }
    
    private func loadStaticMediaFromInet(media: MediaDownloadable, sizeKey: GameImageSizeKey, completion: ((Data?, FetchingError?) -> Void)? = nil) {

        guard let staticMediaRequest = RequestFormer.shared.formRequestForMediaStaticContent(for: media, sizeKey: sizeKey) else {
            completion?(nil, .canNotFormRequest)
            return
        }
        
        dataLoader.load(with: staticMediaRequest){
            data, error in
            if let data = data {
                completion?(data, nil)
            } else {
                completion?(nil, .connectionError)
            }
        }
    }
    

    func bringStaticMediaToCache(media: MediaDownloadable, sizeKey: GameImageSizeKey, completion: ((Data?, FetchingError?) -> Void)? = nil) {
        self.loadStaticMediaFromInet(media: media, sizeKey: sizeKey){
            data, error in
            if let data = data {
                CacheManager.shared.saveStaticMedia(data: data, sizeKey: sizeKey, media: media)
                completion?(data, nil)
            } else {
                completion?(nil, error)
            }
        }
    }
    
    
    func loadFavoriteGames(completion: @escaping ([Game]?) -> Void){
        CacheManager.shared.loadFavoriteGames(completion: completion)
    }
    
    func save(game: Game, completion: ((_ success: Bool) -> Void)? = nil) {
        CacheManager.shared.save(game: game, completion: completion)
    }
    
    func loadGame(with id: Int, completion: @escaping (Game?, FetchingError?) -> Void) {
        CacheManager.shared.loadGame(with: id, completion: completion)
    }
    
    
    func clearImageCache(completion: ((_ success: Bool) -> Void)? = nil) {
        CacheManager.shared.clearAllStaticMediaData(completion: completion)
    }
    
    func clearFavorites(completion: ((_ success: Bool) -> Void)? = nil) {
        CacheManager.shared.clearFavorites(completion: completion)
    }
    
    func updateGame(id: Int, completion: ((_ success: Bool) -> Void)? = nil){
        guard let requestApiItem = GameApiRequestItem.formRequestItemForSpecificGames(gamesIds: [id]) else {
            completion?(false)
            return
        }
        let request = RequestFormer.shared.formRequest(with: requestApiItem)
        jsonLoader.load(request: request) {
            (games: [Game]?, error: NetworkError?) in
            if let game = games?.first {
                self.save(game: game,completion: completion)
            } else {
                completion?(false)
            }
        }
    }
}

enum FetchingError: Error {
    case connectionError
    case canNotFormRequest
    case noCoverId
    case noItemInDb
}
