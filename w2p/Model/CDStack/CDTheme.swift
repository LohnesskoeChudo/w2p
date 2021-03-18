//
//  CDTheme.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDTheme: NSManagedObject{
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, theme: Theme){
        guard let id = theme.id else { return nil }
        guard let name = theme.name else { return nil }
        self.init(entity: entity, insertInto: context)
        self.id = Int64(id)
        self.name = name
        
    }
}

extension Theme {
    convenience init?(cdTheme: CDTheme) {
        self.init()
        self.id = Int(cdTheme.id)
        self.name = cdTheme.name
    }
}
