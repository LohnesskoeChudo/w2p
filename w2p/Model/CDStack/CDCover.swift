//
//  CDCover.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDCover: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, cover: Cover){
        
        guard let id = cover.id else {return nil}
        guard let url = cover.url else {return nil}
        guard let width = cover.width else { return nil }
        guard let height = cover.height else { return nil }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(id)
        self.url = url
        self.height = Int64(height)
        self.width = Int64(width)
        if let isAnimated = cover.animated { self.animated  = isAnimated }
        
        let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: context)!
        let imageData = CDImageData(entity: imageDataEntity, insertInto: context)
        imageData.id = self.id
        imageData.typeId = Int64(StaticMedia.cover.rawValue)
        self.imageData = imageData

    }
    
}

extension Cover {
    convenience init?(cdCover: CDCover) {
        self.init()
        self.id = Int(cdCover.id)
        self.animated = cdCover.animated
        self.url = cdCover.url
        self.height = Int(cdCover.height)
        self.width = Int(cdCover.width)
    }
}
