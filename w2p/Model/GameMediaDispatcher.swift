//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import Foundation

class GameMediaDispatcher{
    
    private let dataLoader = DataLoader()
    
    
    func fetchCoverDataWith(cover: Cover, gameId: Int, cache: Bool, completion: @escaping (Data?, FetchingError?) -> Void){
        
        /*
        if let coverRequest = RequestFormer.shared.formRequestForCover(for: game, sizeKey: .S264X374) {
            loadStaticMediaFromInet(request: coverRequest){
                data, error in
                if let data = data {
                    completion(data, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
        */
        
        
        guard let id = cover.id else {
            completion(nil, .noCoverId)
            return
        }
        CacheManager.shared.loadCover(with: id){
            data in
            if let data = data {
                completion(data, nil)
            } else {
                guard let coverRequest = RequestFormer.shared.formRequestForCover(with: cover, sizeKey: .S264X374) else {
                    completion(nil, .canNotFormRequest)
                    return
                }
                self.loadStaticMediaFromInet(request: coverRequest){
                    data, error in
                    if let data = data {
                        if cache{
                            CacheManager.shared.save(coverData: data, with: cover, gameId: gameId)
                        }
                        completion(data, nil)
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    private func loadStaticMediaFromInet(request: URLRequest, completion: @escaping (Data?, FetchingError?) -> Void) {
        dataLoader.load(with: request){
            data, error in
            if let data = data {
                completion(data, nil)
            } else {
                completion(nil, .connectionError)
            }
        }
    }
    
    func fetchStaticMedia(with media: MediaDownloadable, gameId: Int, cache: Bool = true, completion: @escaping (Data?, FetchingError?) -> Void) {
        CacheManager.shared.loadStaticMedia(with: media){
            data in
            if let data = data {
                completion(data, nil)
            } else {
                guard let staticMediaRequest = RequestFormer.shared.formRequestForMediaStaticContent(for: media, sizeKey: .S889X500) else {
                    completion(nil, .canNotFormRequest)
                    return
                }
                self.loadStaticMediaFromInet(request: staticMediaRequest){
                    data, error in
                    if let data = data {
                        if cache{
                            CacheManager.shared.saveStaticMedia(data: data, media: media, gameId: gameId)
                        }
                        completion(data, nil)
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    
    func loadFavoriteGames(completion: @escaping ([Game]?) -> Void){
        CacheManager.shared.loadFavoriteGames(completion: completion)
    }
    
    func save(game: Game) {
        CacheManager.shared.save(game: game)
    }
    
    
}

enum FetchingError: Error{
    case connectionError
    case canNotFormRequest
    case noCoverId
}
