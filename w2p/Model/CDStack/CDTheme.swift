//
//  CDTheme.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDTheme: NSManagedObject{
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, theme: Theme){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(theme.id)
        self.name = theme.name
    }
}

extension Theme {
    init?(cdTheme: CDTheme) {
        self.id = Int(cdTheme.id)
        if let themeName = cdTheme.name {
            self.name = themeName
        } else {
            return nil
        }
    }
}
