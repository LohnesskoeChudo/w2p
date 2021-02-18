//
//  CDGameItem+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDGameItem)
public class CDGameItem: NSManagedObject {
    
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext, gameItem: GameItem){
        self.init(entity: entity, insertInto: context)
        
        id = Int64(gameItem.id)
        name = gameItem.name
        summary = gameItem.summary
        storyline = gameItem.storyline
        aggregatedRating = gameItem.aggregatedRating ?? -1
        firstReleaseDate = gameItem.firstReleaseDate
        similarGames = gameItem.similarGames
        category = Int64(gameItem.status?.rawValue ?? -1)
        status = Int64(gameItem.status?.rawValue ?? -1)
        gameModes = gameItem.gameModes
        ageCategory = Int64(gameItem.ageCategory?.rawValue ?? -1)
        ageRating = Int64(gameItem.ageRating?.rawValue ?? -1)
        inFavorites = gameItem.inFavorites
        
        if let cover = gameItem.cover{
            let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: context)!
            self.cover = CDCover(entity: coverEntity, insertInto: context, cover: cover)
        }

        let artworkEntity = NSEntityDescription.entity(forEntityName: "CDArtwork", in: context)!
        let artworks: [CDArtwork]? = gameItem.artworks?.map{
            CDArtwork(entity: artworkEntity, insertInto: context, artwork: $0)
        }
        if let artworks = artworks, !artworks.isEmpty{
            self.artworks = NSSet(array: artworks)
        }
        
        
        let websiteEntity = NSEntityDescription.entity(forEntityName: "CDWebsite", in: context)!
        let websites: [CDWebsite]? = gameItem.websites?.map{
            CDWebsite(entity: websiteEntity, insertInto: context, website: $0)
        }
        if let websites = websites, !websites.isEmpty{
            self.websites = NSSet(array: websites)
        }
        
        let screenshotEntity = NSEntityDescription.entity(forEntityName: "CDScreenshot", in: context)!
        let screenshots: [CDScreenshot]? = gameItem.screenshots?.map{
            CDScreenshot(entity: screenshotEntity, insertInto: context, screenshot: $0)
        }
        if let screenshots = screenshots, !screenshots.isEmpty{
            self.screenshots = NSSet(array: screenshots)
        }
        
        let genreEntity = NSEntityDescription.entity(forEntityName: "CDGenre", in: context)!
        let genres: [CDGenre]? = gameItem.genres?.map{
            CDGenre(entity: genreEntity, insertInto: context, genre: $0)
        }
        if let genres = genres, !genres.isEmpty {
            self.genres = NSSet(array: genres)
        }
        
        let platformEntity = NSEntityDescription.entity(forEntityName: "CDPlatform", in: context)!
        let platforms: [CDPlatform]? = gameItem.platforms?.map{
            CDPlatform(entity: platformEntity, insertInto: context, platform: $0)
        }
        if let platforms = platforms, !platforms.isEmpty {
            self.platforms = NSSet(array: platforms)
        }
        
        let themeEntity = NSEntityDescription.entity(forEntityName: "CDTheme", in: context)!
        let themes: [CDTheme]? = gameItem.themes?.map{
            CDTheme(entity: themeEntity, insertInto: context, theme: $0)
        }
        if let themes = themes, !themes.isEmpty {
            self.themes = NSSet(array: themes)
        }
        
        
        if let collection = gameItem.collection{
            let collectionEntity = NSEntityDescription.entity(forEntityName: "CDCollection", in: context)!
            self.collection = CDCollection(entity: collectionEntity, insertInto: context, collection: collection)
        }
        
        if let franchise = gameItem.franchise{
            let franchiseEntity = NSEntityDescription.entity(forEntityName: "CDFranchise", in: context)!
            self.franchise = CDFranchise(entity: franchiseEntity, insertInto: context, franchise: franchise)
        }
    }
}

