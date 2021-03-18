//
//  CDScreenshot.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDScreenshot: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, screenshot: Screenshot){
            
        guard let id = screenshot.id else { return nil }
        guard let height = screenshot.height else { return nil }
        guard let width = screenshot.width else { return nil }
        guard let url = screenshot.url else { return nil }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(id)
        self.height = Int64(height)
        self.width = Int64(width)
        self.url = url
        if let isAnimated = screenshot.animated { self.animated = isAnimated }
        
        let imageDataEntity = NSEntityDescription.entity(forEntityName: "CDImageData", in: context)!
        let imageData = CDImageData(entity: imageDataEntity, insertInto: context)
        imageData.id = self.id
        imageData.typeId = Int64(StaticMedia.screenshot.rawValue)
        self.imageData = imageData
        
    }
    
}


extension Screenshot {
    convenience init? (cdScreenshot: CDScreenshot) {
        self.init()
        self.id = Int(cdScreenshot.id)
        self.height = Int(cdScreenshot.height)
        self.width = Int(cdScreenshot.width)
        self.animated = cdScreenshot.animated
        self.url = cdScreenshot.url
    }
}
