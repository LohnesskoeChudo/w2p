//
//  CDArtwork.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDArtwork: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, artwork: Artwork){
            
        
        guard let id = artwork.id else { return nil }
        guard let url = artwork.url else { return nil }
        guard let width = artwork.width else { return nil }
        guard let height = artwork.height else { return nil }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(id)
        self.height = Int64(height)
        self.width = Int64(width)
        if let isAnimated = artwork.animated { self.animated = isAnimated }
        self.url = url
        

    }
    
}

extension Artwork {
    convenience init? (cdArtwork: CDArtwork) {
        self.init()
        self.id = Int(cdArtwork.id)
        self.height = Int(cdArtwork.height)
        self.width = Int(cdArtwork.width)
        self.animated = cdArtwork.animated
        self.url = cdArtwork.url
    }
}
