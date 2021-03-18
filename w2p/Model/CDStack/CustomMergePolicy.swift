//
//  CustomMergePolicy.swift
//  w2p
//
//  Created by vas on 08.03.2021.
//

import CoreData

class CustomMergePolicy: NSMergePolicy {
    
    
    //let relationKeysToIgnore: Set<String> = ["imageData"]
    
    override func resolve(constraintConflicts list: [NSConstraintConflict]) throws {
        
        

        guard list.allSatisfy({$0.databaseObject != nil}) else {
            return try super.resolve(constraintConflicts: list)
        }
        
        for conflict in list {
            for conflictingObject in conflict.conflictingObjects {
                for key in conflictingObject.entity.attributesByName.keys {
                    let dbValue = conflict.databaseObject?.value(forKey: key)
                    if conflictingObject.value(forKey: key) == nil {
                        conflictingObject.setValue(dbValue, forKey: key)
                    }
                }
                
                for key in conflictingObject.entity.relationshipsByName.keys {
                    
     //               if relationKeysToIgnore.contains(key) { continue }
                    
                    let dbValue = conflict.databaseObject?.value(forKey: key)
                    if conflictingObject.value(forKey: key) == nil {
                        conflictingObject.setValue(dbValue, forKey: key)
                    }
                }
            }
        }
        
        try super.resolve(constraintConflicts: list)
        
    }
}
