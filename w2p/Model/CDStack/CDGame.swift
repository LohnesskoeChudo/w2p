//
//  CDGame.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDGame: NSManagedObject{
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, game: Game){
        
        self.init(entity: entity, insertInto: context)
        
        if let id = game.id{ self.id = Int64(id) }
        if let name = game.name { self.name = name }
        if let summary = game.summary { self.summary = summary }
        if let storyline = game.storyline { self.storyline = storyline }
        if let category = game.category { self.category = Int64(category) }
        if let status = game.status { self.status = Int64(status)}
        if let aggregatedRating = game.aggregatedRating { self.aggregatedRating = aggregatedRating }
        
        if let similarGamesIds = game.similarGames {
            var similarGames = [CDGame]()
            for similarGameId in similarGamesIds{
                let similarGame = CDGame(context: context)
                similarGame.id = Int64(similarGameId)
                similarGames.append(similarGame)
            }
            self.similarGames = NSSet(array: similarGames)
        }
        
        let ageRatingEntity = NSEntityDescription.entity(forEntityName: "CDAgeRating", in: context)!
        if let ageRatings = game.ageRatings{ self.ageRatings = NSSet(array: ageRatings.map{CDAgeRating(context: context, entity: ageRatingEntity, ageRating: $0)})}
        
        let artworkEntity = NSEntityDescription.entity(forEntityName: "CDArtwork", in: context)!
        if let artworks = game.artworks{ self.artworks = NSSet(array: artworks.map{CDArtwork(context: context, entity: artworkEntity, artwork: $0)})}
        
        let screenshotEntity = NSEntityDescription.entity(forEntityName: "CDScreenshot", in: context)!
        if let screenshots = game.screenshots{self.screenshots = NSSet(array: screenshots.map{CDScreenshot(context: context, entity: screenshotEntity, screenshot: $0)})}
        
        let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: context)!
        if let cover = game.cover{ self.cover = CDCover(context: context, entity: coverEntity, cover: cover)}
        
        let genreEntity = NSEntityDescription.entity(forEntityName: "CDGenre", in: context)!
        if let genres = game.genres { self.genres = NSSet(array: genres.map{CDGenre(context: context, entity: genreEntity, genre: $0)})}
        
        let themeEntity = NSEntityDescription.entity(forEntityName: "CDTheme", in: context)!
        if let themes = game.themes {self.themes = NSSet(array: themes.map{CDTheme(context: context, entity: themeEntity, theme: $0)})}
        
        let collectionEntity = NSEntityDescription.entity(forEntityName: "CDGameCollection", in: context)!
        if let gameCollection = game.collection{ self.collection = CDGameCollection(context: context, entity: collectionEntity, collection: gameCollection)}
        
        let franchiseEntity = NSEntityDescription.entity(forEntityName: "CDFranchise", in: context)!
        if let franchise = game.franchise{ self.franchise = CDFranchise(context: context, entity: franchiseEntity, franchise: franchise)}
        
        let gameModeEntity = NSEntityDescription.entity(forEntityName: "CDGameMode", in: context)!
        if let gameModes = game.gameModes{ self.gameModes = NSSet(array: gameModes.map{CDGameMode(context: context, entity: gameModeEntity, gameMode: $0)})}
        
        let platformEntity = NSEntityDescription.entity(forEntityName: "CDPlatform", in: context)!
        if let platforms = game.platforms{ self.platforms = NSSet(array: platforms.map{CDPlatform(context: context, entity: platformEntity, platform: $0)})}
        
        let videoEntity = NSEntityDescription.entity(forEntityName: "CDVideo", in: context)!
        if let videos = game.videos{ self.videos = NSSet(array: videos.map{CDVideo(context: context, entity: videoEntity, video: $0)})}
        
        let websiteEntity = NSEntityDescription.entity(forEntityName: "CDWebsite", in: context)!
        if let websites = game.websites{ self.websites = NSSet(array: websites.map{CDWebsite(context: context, entity: websiteEntity, website: $0)})}
        
    }
}
