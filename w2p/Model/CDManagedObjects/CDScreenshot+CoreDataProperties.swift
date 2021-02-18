//
//  CDScreenshot+CoreDataProperties.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData


extension CDScreenshot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDScreenshot> {
        return NSFetchRequest<CDScreenshot>(entityName: "CDScreenshot")
    }

    @NSManaged public var gameId: Int64
    @NSManaged public var height: Int64
    @NSManaged public var id: Int64
    @NSManaged public var image: Data?
    @NSManaged public var url: String?
    @NSManaged public var width: Int64
    @NSManaged public var gameItem: CDGameItem?

}

extension CDScreenshot : Identifiable {

}
