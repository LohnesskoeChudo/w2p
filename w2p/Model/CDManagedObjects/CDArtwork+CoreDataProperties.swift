//
//  CDArtwork+CoreDataProperties.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData


extension CDArtwork {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDArtwork> {
        return NSFetchRequest<CDArtwork>(entityName: "CDArtwork")
    }

    @NSManaged public var gameId: Int64
    @NSManaged public var height: Int64
    @NSManaged public var id: Int64
    @NSManaged public var image: Data?
    @NSManaged public var url: String?
    @NSManaged public var width: Int64
    @NSManaged public var gameItem: CDGameItem?

}

extension CDArtwork : Identifiable {

}
