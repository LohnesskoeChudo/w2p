//
//  GameRandomizer.swift
//  w2p
//
//  Created by vas on 26.03.2021.
//

import Foundation

class GameRandomizer {

    private var gameDispatcher = Resolver.shared.container.resolve(PGameDispatcher.self)!
    private var poolOfGameIds = Set<Int>()
    static var numberOfRandomGamesPerRequest = 30
    
    func updateApiRequestItemWithNewGames(item: GameApiRequestItem, completion: (()->Void)? = nil) {
        gameDispatcher.getTotalAmountOfGames() {
            total in
            let action = {
                let ids = self.prepareCollectionOfNotShownGames(count: Self.numberOfRandomGamesPerRequest)
                if !ids.isEmpty {
                    item.replaceFilterWithSpecificGamesIds(gameIds: ids)
                } else {
                    item.replaceFilterWithSpecificGamesIds(gameIds: [0])
                }
                completion?()
            }
            DispatchQueue.global(qos: .userInteractive).async {
                if self.poolOfGameIds.isEmpty {
                    self.setupPool(gamesAmount: total) { action() }
                } else {
                    action()
                }
            }
        }
    }
    
    private func setupPool(gamesAmount: Int, completion: @escaping () -> Void) {
        self.poolOfGameIds = Set(1...gamesAmount)
        completion()
    }
    
    private func prepareCollectionOfNotShownGames(count: Int) -> [Int] {
        var collection = [Int]()
        for _ in 0..<count {
            if let id = poolOfGameIds.randomElement() {
                collection.append(id)
                poolOfGameIds.remove(id)
            }
        }
        return collection
    }

    func reset() {
        poolOfGameIds = []
    }
}



