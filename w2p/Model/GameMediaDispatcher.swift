//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import Foundation

class GameMediaDispatcher{
    
    private let dataLoader = DataLoader()
    
    
    func fetchCoverFor(game: Game, cache: Bool, completion: @escaping (Data?, FetchingError?) -> Void){
        
        CacheManager.shared.loadCover(for: game){
            data in
            if let data = data {
                completion(data, nil)
            } else {
                guard let coverRequest = RequestFormer.shared.formRequestForCover(for: game, sizeKey: .S264X374) else {
                    completion(nil, .canNotFormRequest)
                    return
                }
                self.loadStaticMediaFromInet(request: coverRequest){
                    data, error in
                    if let data = data {
                        if cache{
                            CacheManager.shared.save(coverData: data, for: game)
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
                guard let staticMediaRequest = RequestFormer.shared.formRequestForMediaStaticContent(for: media, sizeKey: .S1920X1080) else {
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
}

enum FetchingError: Error{
    case connectionError
    case canNotFormRequest
}
