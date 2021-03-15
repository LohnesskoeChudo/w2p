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
            
        cacheDate = Date()
        
        if let id = game.id{ self.id = Int64(id) }
        if let name = game.name { self.name = name }
        if let summary = game.summary { self.summary = summary }
        if let storyline = game.storyline { self.storyline = storyline }
        if let category = game.category { self.category = Int64(category) }
        if let status = game.status { self.status = Int64(status)}
        if let totalRating = game.totalRating { self.totalRating = totalRating
        }
        if let inFavorites = game.inFavorites {
            self.inFavorites = inFavorites
        }
        
        let companyEntity = NSEntityDescription.entity(forEntityName: "CDCompany", in: context)!
        if let involvedCompanies = game.involvedCompanies {
            var cdCompanies = [CDCompany?]()
            let companies = involvedCompanies.map{$0.company}
            for company in companies{
                if let company = company {
                    cdCompanies.append(CDCompany(context: context, entity: companyEntity, company: company))
                }
            }
            self.companies = NSSet(array: cdCompanies.compactMap{$0})
        }
        
        let gameEngineEntity = NSEntityDescription.entity(forEntityName: "CDGameEngine", in: context)!
        if let engines = game.gameEngines {
            var cdEngines = [CDGameEngine?]()
            for engine in engines {
                cdEngines.append(CDGameEngine(context: context, entity: gameEngineEntity, gameEngine: engine))
            }
            self.engines = NSSet(array: cdEngines.compactMap{$0})
        }
        
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
        if let ageRatings = game.ageRatings{ self.ageRatings = NSSet(array: ageRatings.compactMap{CDAgeRating(context: context, entity: ageRatingEntity, ageRating: $0)})}
        
        let artworkEntity = NSEntityDescription.entity(forEntityName: "CDArtwork", in: context)!
        if let artworks = game.artworks{ self.artworks = NSSet(array: artworks.compactMap{CDArtwork(context: context, entity: artworkEntity, artwork: $0)})}
        
        let screenshotEntity = NSEntityDescription.entity(forEntityName: "CDScreenshot", in: context)!
        if let screenshots = game.screenshots{self.screenshots = NSSet(array: screenshots.compactMap{CDScreenshot(context: context, entity: screenshotEntity, screenshot: $0)})}
        
        let coverEntity = NSEntityDescription.entity(forEntityName: "CDCover", in: context)!
        if let cover = game.cover{ self.cover = CDCover(context: context, entity: coverEntity, cover: cover)}
        
        let genreEntity = NSEntityDescription.entity(forEntityName: "CDGenre", in: context)!
        if let genres = game.genres { self.genres = NSSet(array: genres.compactMap{CDGenre(context: context, entity: genreEntity, genre: $0)})}
        
        let themeEntity = NSEntityDescription.entity(forEntityName: "CDTheme", in: context)!
        if let themes = game.themes {self.themes = NSSet(array: themes.compactMap{CDTheme(context: context, entity: themeEntity, theme: $0)})}
        
        let collectionEntity = NSEntityDescription.entity(forEntityName: "CDGameCollection", in: context)!
        if let gameCollection = game.collection{ self.collection = CDGameCollection(context: context, entity: collectionEntity, collection: gameCollection, generatorGame: self)}
        
        let franchiseEntity = NSEntityDescription.entity(forEntityName: "CDFranchise", in: context)!
        if let franchise = game.franchise{ self.franchise = CDFranchise(context: context, entity: franchiseEntity, franchise: franchise, generatorGame: self)}
        
        let gameModeEntity = NSEntityDescription.entity(forEntityName: "CDGameMode", in: context)!
        if let gameModes = game.gameModes{ self.gameModes = NSSet(array: gameModes.compactMap{CDGameMode(context: context, entity: gameModeEntity, gameMode: $0)})}
        
        let platformEntity = NSEntityDescription.entity(forEntityName: "CDPlatform", in: context)!
        if let platforms = game.platforms{ self.platforms = NSSet(array: platforms.compactMap{CDPlatform(context: context, entity: platformEntity, platform: $0)})}
        
        let videoEntity = NSEntityDescription.entity(forEntityName: "CDVideo", in: context)!
        if let videos = game.videos{ self.videos = NSSet(array: videos.compactMap{CDVideo(context: context, entity: videoEntity, video: $0)})}
        
        let websiteEntity = NSEntityDescription.entity(forEntityName: "CDWebsite", in: context)!
        if let websites = game.websites{ self.websites = NSSet(array: websites.compactMap{CDWebsite(context: context, entity: websiteEntity, website: $0)})}
    }
}

// add similar games

extension Game {
    
    convenience init(cdGame: CDGame) {
        self.init()
        self.id = Int(cdGame.id)
        self.name = cdGame.name
        self.summary = cdGame.summary
        self.storyline = cdGame.storyline
        self.cacheDate = cdGame.cacheDate
        self.inFavorites = cdGame.inFavorites
        self.category = Int(cdGame.category)
        self.totalRating = cdGame.totalRating
        
        if let cdCover = cdGame.cover {
            self.cover = Cover(cdCover: cdCover)
        }
        
        if let cdScreenshots = cdGame.screenshots?.sortedArray(using: []) as? [CDScreenshot]{
            let screenshots = cdScreenshots.compactMap{Screenshot(cdScreenshot: $0)}
            if !screenshots.isEmpty {
                self.screenshots = screenshots
            }
        }
        
        
        if let artworks = cdGame.artworks?.sortedArray(using: []) as? [CDArtwork]{
            let artworks = artworks.compactMap{Artwork(cdArtwork: $0)}
            if !artworks.isEmpty {
                self.artworks = artworks
            }
        }

        if let franchise = cdGame.franchise {
            self.franchise = Franchise(cdFranchise: franchise)
        }
        
        if let gameCollection = cdGame.collection {
            self.collection = GameCollection(cdGameCollection: gameCollection)
        }
        
        if let videos = cdGame.videos?.sortedArray(using: []) as? [CDVideo]{
            let videos = videos.compactMap{Video(cdVideo: $0)}
            if !videos.isEmpty {
                self.videos = videos
            }
        }
        
        if let websites = cdGame.websites?.sortedArray(using: []) as? [CDWebsite]{
            let websites = websites.compactMap{Website(cdWebsite: $0)}
            if !websites.isEmpty {
                self.websites = websites
            }
        }
        
        if let genres = cdGame.genres?.sortedArray(using: []) as? [CDGenre] {
            let genres = genres.compactMap{Genre(cdGenre: $0)}
            if !genres.isEmpty {
                self.genres = genres
            }
        }
        
        if let themes = cdGame.themes?.sortedArray(using: []) as? [CDTheme] {
            let themes = themes.compactMap{Theme(cdTheme: $0)}
            if !themes.isEmpty {
                self.themes = themes
            }
        }
        
        if let platforms = cdGame.platforms?.sortedArray(using: []) as? [CDPlatform] {
            let platforms = platforms.compactMap{Platform(cdPlatform: $0)}
            if !platforms.isEmpty {
                self.platforms = platforms
            }
        }
        
        if let companies = cdGame.companies?.sortedArray(using: []) as? [CDCompany] {
            let companies = companies.compactMap{Company(cdCompany: $0)}
            if !companies.isEmpty {
                self.involvedCompanies = companies.map{
                    company in
                    let invCompany = InvolvedCompany()
                    return invCompany
                }
            }
        }
        
        if let ageRatings = cdGame.ageRatings?.sortedArray(using: []) as? [CDAgeRating]{
            let ageRatings = ageRatings.compactMap{AgeRating(cdAgeRating: $0)}
            if !ageRatings.isEmpty {
                self.ageRatings = ageRatings
            }
        }
        if let gameModes = cdGame.gameModes?.sortedArray(using: []) as? [CDGameMode] {
            let gameModes = gameModes.compactMap{GameMode(cdGameMode: $0)}
            if !gameModes.isEmpty {
                self.gameModes = gameModes
            }
        }
        
        if let gameEngines = cdGame.engines?.sortedArray(using: []) as? [CDGameEngine] {
            let gameEngines = gameEngines.compactMap{GameEngine(cdGameEngine: $0)}
            if !gameEngines.isEmpty {
                self.gameEngines = gameEngines
            }
            
        }
    }
}

