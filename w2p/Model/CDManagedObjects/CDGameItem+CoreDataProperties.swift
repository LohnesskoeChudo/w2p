//
//  CDGameItem+CoreDataProperties.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData


extension CDGameItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGameItem> {
        return NSFetchRequest<CDGameItem>(entityName: "CDGameItem")
    }

    @NSManaged public var ageCategory: Int64
    @NSManaged public var ageRating: Int64
    @NSManaged public var aggregatedRating: Double
    @NSManaged public var category: Int64
    @NSManaged public var firstReleaseDate: Date?
    @NSManaged public var gameModes: [String]?
    @NSManaged public var inFavorites: Bool
    @NSManaged public var name: String?
    @NSManaged public var similarGames: [Int]?
    @NSManaged public var status: Int64
    @NSManaged public var storyline: String?
    @NSManaged public var summary: String?
    @NSManaged public var id: Int64
    @NSManaged public var artworks: NSSet?
    @NSManaged public var collection: CDCollection?
    @NSManaged public var cover: CDCover?
    @NSManaged public var franchise: CDFranchise?
    @NSManaged public var genres: NSSet?
    @NSManaged public var platforms: NSSet?
    @NSManaged public var screenshots: NSSet?
    @NSManaged public var themes: NSSet?
    @NSManaged public var websites: NSSet?

}

// MARK: Generated accessors for artworks
extension CDGameItem {

    @objc(addArtworksObject:)
    @NSManaged public func addToArtworks(_ value: CDArtwork)

    @objc(removeArtworksObject:)
    @NSManaged public func removeFromArtworks(_ value: CDArtwork)

    @objc(addArtworks:)
    @NSManaged public func addToArtworks(_ values: NSSet)

    @objc(removeArtworks:)
    @NSManaged public func removeFromArtworks(_ values: NSSet)

}

// MARK: Generated accessors for genres
extension CDGameItem {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: CDGenre)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: CDGenre)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)

}

// MARK: Generated accessors for platforms
extension CDGameItem {

    @objc(addPlatformsObject:)
    @NSManaged public func addToPlatforms(_ value: CDPlatform)

    @objc(removePlatformsObject:)
    @NSManaged public func removeFromPlatforms(_ value: CDPlatform)

    @objc(addPlatforms:)
    @NSManaged public func addToPlatforms(_ values: NSSet)

    @objc(removePlatforms:)
    @NSManaged public func removeFromPlatforms(_ values: NSSet)

}

// MARK: Generated accessors for screenshots
extension CDGameItem {

    @objc(addScreenshotsObject:)
    @NSManaged public func addToScreenshots(_ value: CDScreenshot)

    @objc(removeScreenshotsObject:)
    @NSManaged public func removeFromScreenshots(_ value: CDScreenshot)

    @objc(addScreenshots:)
    @NSManaged public func addToScreenshots(_ values: NSSet)

    @objc(removeScreenshots:)
    @NSManaged public func removeFromScreenshots(_ values: NSSet)

}

// MARK: Generated accessors for themes
extension CDGameItem {

    @objc(addThemesObject:)
    @NSManaged public func addToThemes(_ value: CDTheme)

    @objc(removeThemesObject:)
    @NSManaged public func removeFromThemes(_ value: CDTheme)

    @objc(addThemes:)
    @NSManaged public func addToThemes(_ values: NSSet)

    @objc(removeThemes:)
    @NSManaged public func removeFromThemes(_ values: NSSet)

}

// MARK: Generated accessors for websites
extension CDGameItem {

    @objc(addWebsitesObject:)
    @NSManaged public func addToWebsites(_ value: CDWebsite)

    @objc(removeWebsitesObject:)
    @NSManaged public func removeFromWebsites(_ value: CDWebsite)

    @objc(addWebsites:)
    @NSManaged public func addToWebsites(_ values: NSSet)

    @objc(removeWebsites:)
    @NSManaged public func removeFromWebsites(_ values: NSSet)

}

extension CDGameItem : Identifiable {

}
