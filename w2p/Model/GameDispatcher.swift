//
//  GameDispatcher.swift
//  w2p
//
//  Created by Vasiliy Klyotskin on 15.04.2021.
//

import Foundation

protocol PGameDispatcher {
    func updateGame(id: Int, completion: ((_ success: Bool) -> Void)?)
    func getTotalAmountOfGames(completion: ((Int) -> Void)?)
}

final class GameDispatcher: PGameDispatcher {
    private let jsonLoader = Resolver.shared.container.resolve(PJsonLoader.self)!
    private let cacheManager = Resolver.shared.container.resolve(PCacheManager.self)!
    private let requestFormer = Resolver.shared.container.resolve(PRequestFormer.self)!
    
    func updateGame(id: Int, completion: ((_ success: Bool) -> Void)? = nil) {
        guard let requestApiItem = GameApiRequestItem.formRequestItemForSpecificGames(gamesIds: [id]) else {
            completion?(false)
            return
        }
        let request = requestFormer.formRequest(with: requestApiItem)
        jsonLoader.load(request: request) {
            (games: [Game]?, error: NetworkError?) in
            if let game = games?.first {
                self.cacheManager.save(game: game, completion: completion)
            } else {
                completion?(false)
            }
        }
    }
    
    func getTotalAmountOfGames(completion: ((Int) -> Void)? = nil) {
        let secondsSinceLastSaving = cacheManager.secondsSinceLastSavingTotalApiGamesCount
        let oneDayInSeconds = 86400
        if let totalAmount = cacheManager.getTotalApiGamesCount(), let secondsSinceLastSaving = secondsSinceLastSaving, secondsSinceLastSaving < oneDayInSeconds {
            completion?(totalAmount)
        } else {
            loadGameApiTotalCount() {
                count in
                if let count = count {
                    self.cacheManager.saveTotalApiGamesCount(value: count)
                    completion?(count)
                } else {
                    let defaultApiValue = 138000
                    completion?(defaultApiValue)
                }
            }
        }
    }
    
    private func loadGameApiTotalCount(completion: ((Int?)->Void)? = nil) {
        let request = requestFormer.formRequestForTotalGameCount()
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
}
