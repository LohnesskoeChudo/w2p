//
//  CDAgeRating.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDAgeRating: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, ageRating: AgeRating){
        
        guard let id = ageRating.id else { return nil }
        guard let rating = ageRating.rating else { return nil }
        guard let category = ageRating.category else { return nil }
        self.init(entity: entity, insertInto: context)
        self.id = Int64(id)
        self.rating = Int64(rating)
        self.category = Int64(category)
        if let ratingCoverUrl = ageRating.ratingCoverUrl { self.ratingCoverUrl = ratingCoverUrl }
    }
    
}


extension AgeRating {
    convenience init? (cdAgeRating: CDAgeRating) {
        self.init()
        self.rating = Int(cdAgeRating.rating)
        self.category = Int(cdAgeRating.category)
        self.ratingCoverUrl = cdAgeRating.ratingCoverUrl
        self.id = Int(cdAgeRating.id)
    }
}
