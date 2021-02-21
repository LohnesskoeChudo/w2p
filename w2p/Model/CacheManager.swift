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
    }
    
    func save(coverData: Data,for game: Game){
        guard let cover = game.cover, let gameId = game.id else {return}
        let gameEntity = NSEntityDescription.entity(forEntityName: "CDGame", in: self.moc)!
        let cdGame = CDGame(entity: gameEntity, insertInto: self.moc)
        cdGame.id = Int64(gameId)
        let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: self.moc)!
        let cdCover = CDCover(context: self.moc, entity: coverEntity, cover: cover)
        cdCover.image = coverData
        cdGame.cover = cdCover
        //MARK: -
        try! self.moc.save()


    }
    
    
    func loadCover(for game: Game, completion: @escaping (Data?) -> Void){

        guard let gameId = game.id else {return}
        let fetchRequest = NSFetchRequest<CDGame>(entityName: "CDGame")
        let propertiesToFetch: [NSString] = ["cover"]
        fetchRequest.propertiesToFetch = propertiesToFetch
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %d", gameId)
        if let fetchedGameItems = try? self.moc.fetch(fetchRequest), let firstGameItem = fetchedGameItems.first{
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
