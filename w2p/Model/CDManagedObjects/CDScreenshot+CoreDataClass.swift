//
//  CDScreenshot+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDScreenshot)
public class CDScreenshot: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, screenshot: GameImage) {

        self.init(entity: entity, insertInto: context)
        
        width = Int64(screenshot.width)
        height = Int64(screenshot.height)
        image = screenshot.data
        url = screenshot.basicUrlStr
        id = Int64(screenshot.id)

    }
}
