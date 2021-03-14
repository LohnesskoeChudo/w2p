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
        self.moc.mergePolicy = CustomMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        privateMoc = container.newBackgroundContext()
        privateMoc.mergePolicy = CustomMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    func save(coverData: Data, with cover: Cover){
        
        let coverDataSize = Double(coverData.count)
        
        privateMoc.perform {
            let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: self.privateMoc)!
            if let cdCover = CDCover(context: self.privateMoc, entity: coverEntity, cover: cover) {
                cdCover.image = coverData
                if let _ = try? self.privateMoc.save() {
                    self.imagesCacheSize.mutate(block: {$0 += coverDataSize})
                    self.saveCacheSize()
                } else {
                    print("Failed to save cover for coverId: \(cover.id ?? -1)")
                }
                
            }
        }
    }

    
    func clearAllImages() {
        
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
    
    
    func loadCover(with coverId: Int, completion: @escaping (Data?) -> Void){
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDCover>(entityName: "CDCover")
            let propertiesToFetch: [NSString] = ["image"]
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %d", coverId)
            if let fetchedGameItems = try? self.privateMoc.fetch(fetchRequest), let firstGameItem = fetchedGameItems.first{
                if let imageData = firstGameItem.image{
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
        
        var id: Int
        var fetchRequest: NSFetchRequest<NSFetchRequestResult>
        
        if let screenshot = media as? Screenshot, let screenshotId = screenshot.id {
            id = screenshotId
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDScreenshot")
        } else if let artwork = media as? Artwork, let artworkId = artwork.id {
            id = artworkId
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDArtwork")
        } else {
            return
        }
        
        let propertiesToFetch: [NSString] = ["image"]
        fetchRequest.propertiesToFetch = propertiesToFetch
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        if let media = try? self.privateMoc.fetch(fetchRequest){
            if let mediaItem = media.first as? CDScreenshot{
                completion(mediaItem.image)
            } else if let mediaItem = media.first as? CDArtwork {
                completion(mediaItem.image)
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    func saveStaticMedia(data: Data, media: MediaDownloadable, gameId: Int) {
        
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
            } else {
                completion?(false)
            }
        }
    }
    
    func loadGame(with id: Int, completion: @escaping (Game?, FetchingError?) -> Void){
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
    
    private func saveScreenshot(data: Data, with screenshot: Screenshot, competion: @escaping (_ success: Bool) -> Void) {
        privateMoc.perform {
            let screenshotEntity = NSEntityDescription.entity(forEntityName: "CDScreenshot", in: self.privateMoc)!
            if let cdScreenshot = CDScreenshot(context: self.privateMoc, entity: screenshotEntity, screenshot: screenshot) {
                cdScreenshot.image = data
                if let _ = try? self.privateMoc.save() {
                    competion(true)
                } else {
                    competion(false)
                }
            }
        }
    }
    

    private func saveArtwork(data: Data, with artwork: Artwork, completion: @escaping (_ success: Bool) -> Void) {
        privateMoc.perform {
            let artworkEntity = NSEntityDescription.entity(forEntityName: "CDArtwork", in: self.privateMoc)!
            if let cdArtwork = CDArtwork(context: self.privateMoc, entity: artworkEntity, artwork: artwork) {
                cdArtwork.image = data
                if let _ = try? self.privateMoc.save() {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
