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
        
        self.rating = Int64(ageRating.rating)
        self.category = Int64(ageRating.category)
        if let ratingCoverUrl = ageRating.ratingCoverUrl { self.ratingCoverUrl = ratingCoverUrl }
    }
    
}
