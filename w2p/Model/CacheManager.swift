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
        self.moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        privateMoc = container.newBackgroundContext()
        privateMoc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
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
}
