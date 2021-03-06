//
//  CDArtwork.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDArtwork: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, artwork: Artwork){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(artwork.id)
        self.height = Int64(artwork.height)
        self.width = Int64(artwork.width)
        if let isAnimated = artwork.animated { self.animated = isAnimated }
        self.url = artwork.url
        
    }
    
}

extension Artwork {
    init? (cdArtwork: CDArtwork) {
        self.id = Int(cdArtwork.id)
        self.height = Int(cdArtwork.height)
        self.width = Int(cdArtwork.width)
        self.animated = cdArtwork.animated
        if let url = cdArtwork.url {
            self.url = url
        } else {
            return nil
        }
    }
}
