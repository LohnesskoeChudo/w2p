//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import Foundation

class GameMediaDispatcher{
    
    private let dataLoader = DataLoader()
    private let jsonLoader = JsonLoader()

    
    func fetchStaticMedia(with media: MediaDownloadable, cache: Bool = true, completion: ((Data?, FetchingError?) -> Void)? = nil) {
        CacheManager.shared.loadStaticMedia(with: media){
            data in
            if let data = data {
                completion?(data, nil)
            } else {
                if cache {
                    self.bringStaticMediaToCache(media: media, completion: completion)
                } else {
                    self.loadStaticMediaFromInet(media: media, completion: completion)
                }
            }
        }
    }
    
    private func loadStaticMediaFromInet(media: MediaDownloadable, completion: ((Data?, FetchingError?) -> Void)? = nil) {
        
        let sizeKey: GameImageSizeKey
        
        if (media as? Cover) != nil {
            sizeKey = .S264X374
        } else {
            sizeKey = .S889X500
        }
        
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
    

    func bringStaticMediaToCache(media: MediaDownloadable, completion: ((Data?, FetchingError?) -> Void)? = nil) {
        self.loadStaticMediaFromInet(media: media){
            data, error in
            if let data = data {
                CacheManager.shared.saveStaticMedia(data: data, media: media)
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
        jsonLoader.load(request: request){
            (games: [Game]?, error: NetworkError?) in
            if let game = games?.first {
                self.save(game: game,completion: completion)
            } else {
                completion?(false)
            }
        }
    }
}

enum FetchingError: Error{
    case connectionError
    case canNotFormRequest
    case noCoverId
    case noItemInDb
}
