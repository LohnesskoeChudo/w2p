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
                self.loadCoverFromInet(game: game){
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
    
    private func loadCoverFromInet(game: Game, completion: @escaping (Data?, FetchingError?) -> Void){
        guard let basicUrlString = game.cover?.url else {return}
        guard let request = RequestFormer.shared.formSizedImageRequest(basicImageUrl: basicUrlString, sizeKey: .S264X374) else {return}
        dataLoader.load(with: request){
            data, error in
            if let data = data {
                completion(data, nil)
            } else {
                completion(nil, .connectionError)
            }
        }
    }
}

enum FetchingError: Error{
    case connectionError
}
