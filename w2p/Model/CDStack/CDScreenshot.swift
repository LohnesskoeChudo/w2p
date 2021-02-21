//
//  CDScreenshot.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDScreenshot: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, screenshot: Screenshot){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(screenshot.id)
        self.height = Int64(screenshot.height)
        self.width = Int64(screenshot.width)
        if let isAnimated = screenshot.animated { self.animated = isAnimated }
        self.url = screenshot.url
        
    }
    
}
