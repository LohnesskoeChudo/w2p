//
//  CDAgeRating.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDAgeRating: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, ageRating: AgeRating){
        
        self.init(entity: entity, insertInto: context)
        self.id = Int64(ageRating.id)
        self.rating = Int64(ageRating.rating)
        self.category = Int64(ageRating.category)
        if let ratingCoverUrl = ageRating.ratingCoverUrl { self.ratingCoverUrl = ratingCoverUrl }
    }
    
}


extension AgeRating {
    init? (cdAgeRating: CDAgeRating) {
        self.rating = Int(cdAgeRating.rating)
        self.category = Int(cdAgeRating.category)
        if let ratingCoverUrl = cdAgeRating.ratingCoverUrl {
            self.ratingCoverUrl = ratingCoverUrl
        } else {
            return nil
        }
        self.id = Int(cdAgeRating.id)
    }
}
