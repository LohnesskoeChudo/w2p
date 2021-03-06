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
        self.moc.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        privateMoc = container.newBackgroundContext()
        privateMoc.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
    }
    
    func save(coverData: Data,for game: Game){
        guard let cover = game.cover, let gameId = game.id else {return}
        privateMoc.perform {
            let gameEntity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.privateMoc)!
            let cdGame = CDGame(entity: gameEntity, insertInto: self.privateMoc)
            cdGame.id = Int64(gameId)
            let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: self.privateMoc)!
            let cdCover = CDCover(context: self.privateMoc, entity: coverEntity, cover: cover)
            cdCover.image = coverData
            cdGame.cover = cdCover
            //MARK: -
            try! self.privateMoc.save()
        }
    }


    
    func loadCover(for game: Game, completion: @escaping (Data?) -> Void){
        guard let gameId = game.id else {return}
        privateMoc.perform {
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            let propertiesToFetch: [NSString] = ["cover"]
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %d", gameId)
            if let fetchedGameItems = try? self.privateMoc.fetch(fetchRequest), let firstGameItem = fetchedGameItems.first{
                if let imageData = firstGameItem.cover?.image{
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
        
        if let screenshot = media as? Screenshot {
            id = screenshot.id
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDScreenshot")
        } else if let artwork = media as? Artwork {
            id = artwork.id
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
        if let screenshot = media as? Screenshot {
            saveScreenshot(data: data, with: screenshot, gameId: gameId)
        } else if let artwork = media as? Artwork {
            saveArtwork(data: data, with: artwork, gameId: gameId)
        }
    }
    
    func loadFavoriteGames(completion: @escaping ([Game]?) -> Void){
        privateMoc.perform {
            print("in private moc")
            let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
            fetchRequest.predicate = NSPredicate(format: "inFavorites == YES")
            
            
            if let cdGames = try? self.privateMoc.fetch(fetchRequest) {
                let games = cdGames.map{ Game(cdGame: $0)}
                for game in games {
                    print(game.inFavorites)
                }
                print(games.count)
                completion(games)
            } else {
                print("NO GAMES")
                completion(nil)
            }
        }
    }
    
    
    func save(game: Game) {
        privateMoc.perform {
            let entity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.privateMoc)!
            let cdGame = CDGame(context: self.privateMoc, entity: entity, game: game)
            print(cdGame.name)
            //MARK: -
            try! self.privateMoc.save()
        }
    }
    
    private func saveScreenshot(data: Data, with screenshot: Screenshot, gameId: Int) {
        privateMoc.perform {
            let gameEntity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.privateMoc)!
            let cdGame = CDGame(entity: gameEntity, insertInto: self.privateMoc)
            cdGame.id = Int64(gameId)
            let screenshotEntity = NSEntityDescription.entity(forEntityName: "CDScreenshot", in: self.privateMoc)!
            let cdScreenshot = CDScreenshot(context: self.privateMoc, entity: screenshotEntity, screenshot: screenshot)
            cdScreenshot.image = data
            cdGame.addToScreenshots(cdScreenshot)
            try! self.privateMoc.save()
        }
    }
    
    private func saveArtwork(data: Data, with artwork: Artwork, gameId: Int) {
        privateMoc.perform {
            let gameEntity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.privateMoc)!
            let cdGame = CDGame(entity: gameEntity, insertInto: self.privateMoc)
            cdGame.id = Int64(gameId)
            let artworkEntity = NSEntityDescription.entity(forEntityName: "CDArtwork", in: self.privateMoc)!
            let cdArtwork = CDArtwork(context: self.privateMoc, entity: artworkEntity, artwork: artwork)
            cdArtwork.image = data
            cdGame.addToArtworks(cdArtwork)
            try! self.privateMoc.save()
        }
    }
}
