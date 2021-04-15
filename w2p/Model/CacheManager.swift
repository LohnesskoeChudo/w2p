//
//  CacheManager.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import CoreData

protocol PCacheManager {
    func loadCoverData(with coverId: Int, completion: ((Data?) -> Void)?)
    func loadStaticMedia(with media: MediaDownloadable, sizeKey: GameImageSizeKey?, completion: ((Data?) -> Void)?)
    func loadFavoriteGames(completion: (([Game]?) -> Void)?)
    func loadGame(with id: Int, completion: ((Game?, FetchingError?) -> Void)?)
    func clearAllStaticMediaData(completion: ((_ success: Bool) -> Void)?)
    func clearFavorites(completion: ((_ success: Bool) -> Void)?)
    func save(game: Game, completion: ((_ success: Bool) -> Void)?)
    func saveTotalApiGamesCount(value: Int)
    func saveStaticMedia(data: Data, sizeKey: GameImageSizeKey, media: MediaDownloadable)
    func getTotalApiGamesCount() -> Int?
    var secondsSinceLastSavingTotalApiGamesCount: Int? { get }
}

class CacheManager: PCacheManager {
    
    static var shared = CacheManager()
    
    private var container: NSPersistentContainer
    private var moc: NSManagedObjectContext
    private var privateMoc: NSManagedObjectContext
    private var imagesCacheSize = Atomic(UserDefaults.standard.double(forKey: UserDefaults.keyForCachedImagesSize))
    var secondsSinceLastSavingTotalApiGamesCount: Int? {
        let lastValue = UserDefaults.standard.integer(forKey: UserDefaults.keyForLastTotalGamesApiAmountSavingDate)
        if lastValue > 0 {
            return Int(Date(timeIntervalSinceNow: 0).timeIntervalSince1970) - lastValue
        } else {
            return nil
        }
    }
    
    private init() {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores {
            description, error in
            if error != nil {
                fatalError("Can not load persistent stores")
            }
        }
        self.container = container
        self.moc = container.viewContext
        self.moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        privateMoc = container.newBackgroundContext()
        privateMoc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "cacheCleared"), object: nil, queue: nil) { [weak self] _ in
            self?.clearCacheSize()
        }
    }

    func clearFavorites (completion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            fetchRequest.predicate = NSPredicate(format: "inFavorites == YES")
            if let cdGames = try? self.privateMoc.fetch(fetchRequest) {
                for cdGame in cdGames {
                    cdGame.inFavorites = false
                }
                if let _ = try? self.privateMoc.save() {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }
    }

    func loadCoverData(with coverId: Int, completion: ((Data?) -> Void)? = nil) {
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDImageData>(entityName: "CDImageData")
            let propertiesToFetch: [NSString] = ["data"]
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "(id == %d) AND (typeId == \(StaticMedia.cover.rawValue))", coverId)
            if let fetchedData = try? self.privateMoc.fetch(fetchRequest).first {
                if let imageData = fetchedData.data {
                    completion?(imageData)
                } else {
                    completion?(nil)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    func loadStaticMedia(with media: MediaDownloadable, sizeKey: GameImageSizeKey?, completion: ((Data?) -> Void)? = nil) {
        guard let id = media.id else {
            completion?(nil)
            return
        }

        self.privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDImageData>(entityName: "CDImageData")
            let propertiesToFetch: [NSString] = ["data"]
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.fetchLimit = GameImageSizeKey.allCases.count
            
            let typeId: Int
            
            if let _ = media as? Cover {
                typeId = StaticMedia.cover.rawValue
            } else if let _ = media as? Screenshot {
                typeId = StaticMedia.screenshot.rawValue
            } else if let _ = media as? Artwork {
                typeId = StaticMedia.artwork.rawValue
            } else {
                completion?(nil)
                return
            }
            
            if let sizeKey = sizeKey {
                fetchRequest.predicate = NSPredicate(format: "(id == %d) AND (typeId == %d) AND (sizeKey == %s)", id, typeId, sizeKey.rawValue)
                fetchRequest.fetchLimit = 1
            } else {
                fetchRequest.predicate = NSPredicate(format: "(id == %@) AND (typeId == %@)", id, typeId)
            }
            
            if let result = try? self.privateMoc.fetch(fetchRequest), !result.isEmpty {
                if result.count == 1 {
                    completion?(result.first?.data)
                } else {
                    var cdImageDataToReturn = result.first!
                    for cdImageData in result {
                        guard let sizeStr = cdImageData.sizeKey, let sizeKey = GameImageSizeKey(rawValue: sizeStr) else { continue }
                        guard let sizeStrDataToReturn = cdImageDataToReturn.sizeKey, let sizeKeyDataToReturn = GameImageSizeKey(rawValue: sizeStrDataToReturn) else { continue }
                        if sizeKey.measure > sizeKeyDataToReturn.measure {
                            cdImageDataToReturn = cdImageData
                        }
                    }
                    completion?(cdImageDataToReturn.data)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    func saveStaticMedia(data: Data, sizeKey: GameImageSizeKey, media: MediaDownloadable) {
        let dataSize = Double(data.count)
        let succesAction = { (_ success: Bool) -> Void in
            if success {
                self.imagesCacheSize.mutate(block: { $0 += dataSize })
                self.saveCacheSize()
            }
        }
        
        if let screenshot = media as? Screenshot {
            saveScreenshot(data: data, sizeKey: sizeKey.rawValue, with: screenshot, competion: succesAction)
        } else if let artwork = media as? Artwork {
            saveArtwork(data: data, sizeKey: sizeKey.rawValue, with: artwork, completion: succesAction)
        } else if let cover = media as? Cover {
            saveCover(coverData: data, sizeKey: sizeKey.rawValue, with: cover, completion: succesAction)
        }
    }
    
    func loadFavoriteGames(completion: (([Game]?) -> Void)? = nil) {
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            fetchRequest.predicate = NSPredicate(format: "inFavorites == YES")
            if let cdGames = try? self.privateMoc.fetch(fetchRequest) {
                let games = cdGames.map{ Game(cdGame: $0) }
                completion?(games)
            } else {
                completion?(nil)
            }
        }
    }
    
    func save(game: Game, completion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            let entity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.privateMoc)!
            let _ = CDGame(context: self.privateMoc, entity: entity, game: game)
            if let _ = try? self.privateMoc.save() {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func loadGame(with id: Int, completion: ((Game?, FetchingError?) -> Void)? = nil) {
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            if let cdGame = try? self.privateMoc.fetch(fetchRequest).first {
                let game = Game(cdGame: cdGame)
                completion?(game, nil)
            } else {
                completion?(nil, .noItemInDb)
            }
        }
    }
    
    
    func clearAllStaticMediaData(completion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDImageData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            if let _ = try? self.container.persistentStoreCoordinator.execute(deleteRequest, with: self.privateMoc) {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }

    func getTotalApiGamesCount() -> Int? {
        let totalGamesCountInApi = UserDefaults.standard.integer(forKey: UserDefaults.keyForTotalGamesAmountInApi)
        if totalGamesCountInApi > 0 {
            return totalGamesCountInApi
        } else {
            return nil
        }
    }
    
    func saveTotalApiGamesCount(value: Int) {
        UserDefaults.standard.setValue(value, forKey: UserDefaults.keyForTotalGamesAmountInApi)
        UserDefaults.standard.setValue( Int(Date(timeIntervalSinceNow: 0).timeIntervalSince1970), forKey: UserDefaults.keyForLastTotalGamesApiAmountSavingDate)
    }

    private func saveCover(coverData: Data, sizeKey: String, with cover: Cover, completion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            guard let coverId = cover.id else {
                completion?(false)
                return
            }
            let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: self.privateMoc)!
            let cdImageData = CDImageData(entity: imageDataEntity, insertInto: self.privateMoc)
            cdImageData.data = coverData
            cdImageData.id = Int64(coverId)
            cdImageData.typeId = Int64(StaticMedia.cover.rawValue)
            cdImageData.sizeKey = sizeKey
            if let _ = try? self.privateMoc.save() {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }

    private func saveScreenshot(data: Data, sizeKey: String, with screenshot: Screenshot, competion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            guard let screenshotId = screenshot.id else {
                competion?(false)
                return
            }
            let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: self.privateMoc)!
            let cdImageData = CDImageData(entity: imageDataEntity, insertInto: self.privateMoc)
            cdImageData.id = Int64(screenshotId)
            cdImageData.typeId = Int64(StaticMedia.screenshot.rawValue)
            cdImageData.data = data
            cdImageData.sizeKey = sizeKey
            if let _ = try? self.privateMoc.save() {
                competion?(true)
            } else {
                competion?(false)
            }
        }
    }
    
    private func saveArtwork(data: Data, sizeKey: String, with artwork: Artwork, completion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            guard let artworkId = artwork.id else {
                completion?(false)
                return
            }
            let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: self.privateMoc)!
            let cdImageData = CDImageData(entity: imageDataEntity, insertInto: self.privateMoc)
            cdImageData.id = Int64(artworkId)
            cdImageData.typeId = Int64(StaticMedia.artwork.rawValue)
            cdImageData.data = data
            cdImageData.sizeKey = sizeKey

            if let _ = try? self.privateMoc.save() {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
   
    private func saveCacheSize() {
        UserDefaults.standard.setValue(imagesCacheSize.value, forKey: UserDefaults.keyForCachedImagesSize)
    }
    
    private func clearCacheSize() {
        imagesCacheSize.mutate{$0 = 0}
    }
}

enum StaticMedia: Int {
    case cover = 1
    case artwork = 2
    case screenshot = 3
}
