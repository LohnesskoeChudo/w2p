//
//  BaseDependencies.swift
//  w2p
//
//  Created by Vasiliy Klyotskin on 15.04.2021.
//

import Foundation

final class BaseDependencies {
    static func register() {
        let resolver = Resolver.shared
        resolver.container.register(PDataLoader.self) { _ in
            DataLoader()
        }
        resolver.container.register(PImageLoader.self) { _ in
            ImageLoader()
        }
        resolver.container.register(PJsonLoader.self) { _ in
            JsonLoader()
        }
        resolver.container.register(PMediaDispatcher.self) { _ in
            MediaDispatcher(cache: true)
        }
        resolver.container.register(PGameDispatcher.self) { _ in
            GameDispatcher()
        }
        resolver.container.register(PCacheManager.self) { _ in
            CacheManager.shared
        }
        resolver.container.register(PRequestFormer.self) { _ in
            RequestFormer.shared
        }
    }
}
