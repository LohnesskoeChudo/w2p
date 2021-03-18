//
//  CacheManager.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import CoreData


class CacheManager{
    
    static var shared = CacheManager()
    
    private var container: NSPersistentContainer
    private var moc: NSManagedObjectContext
    private var privateMoc: NSManagedObjectContext
    
    private var imagesCacheSize = Atomic(UserDefaults.standard.double(forKey: UserDefaults.keyForCachedImagesSize))
    
    private func saveCacheSize() {
        UserDefaults.standard.setValue(imagesCacheSize.value, forKey: UserDefaults.keyForCachedImagesSize)
    }
    
    private init(){
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores{
            description, error in
            if error != nil{
                fatalError("Can not load persistent stores")
            }
        }
        self.container = container
        self.moc = container.viewContext
        //self.moc.mergePolicy = CustomMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        self.moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.moc.automaticallyMergesChangesFromParent = true

        privateMoc = container.newBackgroundContext()
        //privateMoc.mergePolicy = CustomMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        self.privateMoc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    }
    
    func printGameCount() {
        self.privateMoc.perform {
            let fetchreq = NSFetchRequest<CDGame>(entityName: "CDGame")
            if let res = try? self.privateMoc.fetch(fetchreq) {
                print("-----------------")
                for k in res {
                    print(k.id)
                }
                print("-----------------")
            }
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
    
    
    func loadCoverData(with coverId: Int, completion: @escaping (Data?) -> Void){
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDImageData>(entityName: "CDImageData")
            let propertiesToFetch: [NSString] = ["data"]
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "(id == %d) AND (typeId == \(StaticMedia.cover.rawValue))", coverId)
            if let fetchedData = try? self.privateMoc.fetch(fetchRequest).first {
                if let imageData = fetchedData.data{
                    completion(imageData)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func loadStaticMedia(with media: MediaDownloadable, completion: @escaping (Data?) -> Void){
        
        guard let id = media.id else {
            completion(nil)
            return
        }
        
        self.privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDImageData>(entityName: "CDImageData")
            let propertiesToFetch: [NSString] = ["data"]
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.fetchLimit = 1
            
            let typeId: Int
            
            if let _ = media as? Cover {
                typeId = StaticMedia.cover.rawValue
            } else if let _ = media as? Screenshot {
                typeId = StaticMedia.screenshot.rawValue
            } else if let _ = media as? Artwork {
                typeId = StaticMedia.artwork.rawValue
            } else {
                completion(nil)
                return
            }
            fetchRequest.predicate = NSPredicate(format: "(id == %d) AND (typeId == \(typeId))", id)
            
            if let cdImageData = try? self.privateMoc.fetch(fetchRequest).first {
                if let data = cdImageData.data{
                    completion(data)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func saveStaticMedia(data: Data, media: MediaDownloadable) {
        let dataSize = Double(data.count)
        let succesAction = { (_ success: Bool) -> Void in
            if success {
                self.imagesCacheSize.mutate(block: {$0 += dataSize})
                self.saveCacheSize()
            }
        }
        
        if let screenshot = media as? Screenshot {
            saveScreenshot(data: data, with: screenshot, competion: succesAction)
        } else if let artwork = media as? Artwork {
            saveArtwork(data: data, with: artwork, completion: succesAction)
        } else if let cover = media as? Cover {
            saveCover(coverData: data, with: cover, completion: succesAction)
        }
    }
    
    func loadFavoriteGames(completion: @escaping ([Game]?) -> Void){
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            fetchRequest.predicate = NSPredicate(format: "inFavorites == YES")
            if let cdGames = try? self.privateMoc.fetch(fetchRequest) {
                let games = cdGames.map{ Game(cdGame: $0)}
                completion(games)
            } else {
                completion(nil)
            }
        }
    }
    
    
    func save(game: Game, completion: ((_ success: Bool) -> Void)? = nil) {
        privateMoc.perform {
            let entity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.privateMoc)!
            let _ = CDGame(context: self.privateMoc, entity: entity, game: game)
            if let _ = try? self.privateMoc.save() {
                completion?(true)
                self.printGameCount()
            } else {
                completion?(false)
                self.printGameCount()
            }
        }
    }
    
    func loadGame(with id: Int, completion: @escaping (Game?, FetchingError?) -> Void){
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            if let cdGame = try? self.privateMoc.fetch(fetchRequest).first {
                let game = Game(cdGame: cdGame)
                completion(game, nil)
            } else {
                completion(nil, .noItemInDb)
            }
        }
    }

    
    func saveCover(coverData: Data, with cover: Cover, completion: ((_ success: Bool) -> Void)? = nil){
        
        privateMoc.perform {
            let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: self.privateMoc)!
            if let cdCover = CDCover(context: self.privateMoc, entity: coverEntity, cover: cover) {
                let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: self.privateMoc)!
                let cdImageData = CDImageData(entity: imageDataEntity, insertInto: self.privateMoc)
                cdImageData.data = coverData
                cdImageData.id = cdCover.id
                cdImageData.typeId = Int64(StaticMedia.cover.rawValue)
                cdCover.imageData = cdImageData
                if let _ = try? self.privateMoc.save() {
                    completion?(true)
                } else {
                    completion?(false)
                }
                
            }
        }
    }

    
    func saveScreenshot(data: Data, with screenshot: Screenshot, competion: @escaping (_ success: Bool) -> Void) {
        privateMoc.perform {
            let screenshotEntity = NSEntityDescription.entity(forEntityName: "CDScreenshot", in: self.privateMoc)!
            if let cdScreenshot = CDScreenshot(context: self.privateMoc, entity: screenshotEntity, screenshot: screenshot) {
                let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: self.privateMoc)!
                let cdImageData = CDImageData(entity: imageDataEntity, insertInto: self.privateMoc)
                cdImageData.id = cdScreenshot.id
                cdImageData.typeId = Int64(StaticMedia.screenshot.rawValue)
                cdImageData.data = data
                cdScreenshot.imageData = cdImageData
                if let _ = try? self.privateMoc.save() {
                    competion(true)
                } else {
                    competion(false)
                }
            }
        }
    }
    

    func saveArtwork(data: Data, with artwork: Artwork, completion: @escaping (_ success: Bool) -> Void) {
        privateMoc.perform {
            let artworkEntity = NSEntityDescription.entity(forEntityName: "CDArtwork", in: self.privateMoc)!
            if let cdArtwork = CDArtwork(context: self.privateMoc, entity: artworkEntity, artwork: artwork) {
                
                let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: self.privateMoc)!
                let cdImageData = CDImageData(entity: imageDataEntity, insertInto: self.privateMoc)
                cdImageData.id = cdArtwork.id
                cdImageData.typeId = Int64(StaticMedia.artwork.rawValue)
                cdImageData.data = data
                cdArtwork.imageData = cdImageData
                
                if let _ = try? self.privateMoc.save() {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func clearAllStaticMediaData(completion: ((_ success: Bool) -> Void)? = nil) {
        print("Called")
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDImageData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            if let _ = try? self.container.persistentStoreCoordinator.execute(deleteRequest, with: self.privateMoc) {
                completion?(true)
                print("Success")
            } else {
                completion?(false)
                print("Failure")
            }
        }

    }
}

enum StaticMedia: Int {
    case cover = 1
    case artwork = 2
    case screenshot = 3
}
