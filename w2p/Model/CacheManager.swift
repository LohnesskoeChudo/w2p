//
//  CacheManager.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//
import CoreData


class CacheManager{
    
    static var shared = CacheManager()
            
    private let container: NSPersistentContainer
    private let moc: NSManagedObjectContext
    
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
        moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        
    }
    
    func saveCover(for gameItem: GameItem){
        guard let cover = gameItem.cover else {return}
        let gameEntity = NSEntityDescription.entity(forEntityName: "CDGameItem", in: moc)!
        let cdGameItem = CDGameItem(entity: gameEntity, insertInto: moc)
        cdGameItem.id = Int64(gameItem.id)
        let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: moc)!
        let cdCover = CDCover(entity: coverEntity, insertInto: moc, cover: cover)
        cdGameItem.cover = cdCover
        try! moc.save()
    }
    
    func loadCover(for gameItem: GameItem, completion: (Data?) -> Void){
        let fetchRequest = NSFetchRequest<CDGameItem>(entityName: "CDGameItem")
        let propertiesToFetch: [NSString] = ["cover"]
        fetchRequest.propertiesToFetch = propertiesToFetch
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %d", gameItem.id)

        if let fetchedGameItems = try? moc.fetch(fetchRequest), let firstGameItem = fetchedGameItems.first{
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

protocol Predicate {}
extension NSPredicate: Predicate {}
