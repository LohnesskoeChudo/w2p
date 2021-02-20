//
//  ImageLoader.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import Foundation

class GameMediaDispatcher{
    
    private let dataLoader = DataLoader()
    
    
    func fetchCover(gameItem: GameItem, completion: @escaping (Data?) -> Void){
        CacheManager.shared.loadCover(for: gameItem){
            data in
            if let data = data {
                completion(data)
            } else {
                loadCoverFromInet(gameItem: gameItem){
                    data in
                    if let data = data {
                        CacheManager.shared.save(coverData: data, for: gameItem)
                    }
                    completion(data)
                }
            }
        }
    }
    
    private func loadCoverFromInet(gameItem: GameItem, completion: @escaping (Data?) -> Void){
        guard let basicUrlString = gameItem.cover?.basicUrlStr else {return}
        guard let request = RequestFormer.shared.formSizedImageRequest(basicImageUrl: basicUrlString, sizeKey: .S264X374) else {return}
        dataLoader.load(with: request){
            data, error in

            if let data = data {
                completion(data)
            }
        }
    }
    
}
