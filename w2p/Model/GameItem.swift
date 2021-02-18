//
//  GameCard.swift
//  what2play
//
//  Created by vas on 04.02.2021.
//

import Foundation

class GameItem {
    
    var id: Int
    var name: String
    var summary: String?
    var storyline: String?
    var aggregatedRating: Double?
    var firstReleaseDate: Date?
    var similarGames: [Int]?
    var category: GameCategory?
    var status: GameStatus?
    var gameModes: [String]?
    var websites: [GameWebsite]?
    var ageCategory: GameAgeCategory?
    var ageRating: GameAgeRating?
    var inFavorites: Bool
    var cover: GameImage?
    var artworks: [GameImage]?
    var screenshots: [GameImage]?
    var genres: [GameGenre]?
    var platforms: [GamePlatform]?
    var themes: [GameTheme]?
    var collection: GameCollection?
    var franchise: GameFranchise?
    var videos: [GameVideo]?
    

    init(jsonGame: JSONGame) {
        id = jsonGame.id
        name = jsonGame.name
        summary = jsonGame.summary
        storyline = jsonGame.storyline
        aggregatedRating = jsonGame.aggregatedRating
        firstReleaseDate = jsonGame.firstReleaseDate
        similarGames = jsonGame.similarGames
        inFavorites = false
        if let category = jsonGame.category{
            self.category = GameCategory(rawValue: category)
        }
        if let status = jsonGame.status{
            self.status = GameStatus(rawValue: status)
        }
        if let jsonCover = jsonGame.cover{
            self.cover = GameImage(id: jsonCover.id, width: jsonCover.width, height: jsonCover.height, basicUrlStr: jsonCover.url)
        }
        if let franchise = jsonGame.franchise{
            self.franchise = GameFranchise(name: franchise.name, id: franchise.id, gameIds: franchise.games)
        }
        if let collection = jsonGame.collection{
            self.collection = GameCollection(name: collection.name, id: collection.id, gameIds: collection.games)
        }
        if let firstAgeRating = jsonGame.ageRatings?.first{
            ageCategory = GameAgeCategory(rawValue: firstAgeRating.category)
            ageRating = GameAgeRating(rawValue: firstAgeRating.rating)
        }
        genres = jsonGame.genres?.map{ GameGenre(name: $0.name, id: $0.id) }
        platforms = jsonGame.platforms?.map{ GamePlatform(name: $0.name, id: $0.id) }
        gameModes = jsonGame.gameModes?.map{ $0.name }
        websites = jsonGame.websites?.map{ GameWebsite(websiteId: $0.category, urlStr: $0.url) }
        themes = jsonGame.themes?.map{ GameTheme(name: $0.name, id: $0.id)}
        artworks = jsonGame.artworks?.map{
            GameImage(id: $0.id,width: $0.width, height: $0.height, basicUrlStr: $0.url)
        }
        screenshots = jsonGame.screenshots?.map{
            GameImage(id: $0.id, width: $0.width, height: $0.height, basicUrlStr: $0.url)
        }
        videos = jsonGame.videos?.map{
            GameVideo(name: $0.name, videoId: $0.videoId)
        }
    }
    
    init(cdGameItem: CDGameItem) {
        id = Int(cdGameItem.id)
        name = cdGameItem.name ?? ""
        summary = cdGameItem.summary ?? ""
        storyline = cdGameItem.storyline
        if cdGameItem.aggregatedRating < 0{
            self.aggregatedRating = nil
        } else {
            self.aggregatedRating = cdGameItem.aggregatedRating
        }
        firstReleaseDate = cdGameItem.firstReleaseDate
        similarGames = cdGameItem.similarGames
        category = GameCategory(rawValue: Int(cdGameItem.category))
        status = GameStatus(rawValue: Int(cdGameItem.status))
        gameModes = cdGameItem.gameModes
        inFavorites = cdGameItem.inFavorites
        websites = cdGameItem.websites?.map{
            let cdWebsite = $0 as! CDWebsite
            var websiteId: Int?
            if cdWebsite.id < 0{
                websiteId = nil
            } else {
                websiteId = Int(cdWebsite.id)
            }
            return GameWebsite(websiteId: websiteId, urlStr: cdWebsite.url ?? "")
        }
        if cdGameItem.ageCategory < 0 {
            ageCategory = nil
        } else {
            ageCategory = GameAgeCategory(rawValue: Int(cdGameItem.ageCategory))
        }
        if cdGameItem.ageRating < 0 {
            ageRating = nil
        } else {
            ageRating = GameAgeRating(rawValue: Int(cdGameItem.ageRating))
        }
        if let cover = cdGameItem.cover{
            self.cover = GameImage(id: Int(cover.id) ,width: Int(cover.width), height: Int(cover.height), basicUrlStr: cover.url)
        }
        self.artworks = cdGameItem.artworks?.map{
            let artwork = $0 as! CDArtwork
            return GameImage(id: Int(artwork.id),width: Int(artwork.width), height: Int(artwork.height), basicUrlStr: artwork.url)
        }
        self.screenshots = cdGameItem.screenshots?.map{
            let screenshot = $0 as! CDScreenshot
            return GameImage(id: Int(screenshot.id),width: Int(screenshot.width), height: Int(screenshot.height), basicUrlStr: screenshot.url)
        }
        self.genres = cdGameItem.genres?.map{
            let genre = $0 as! CDGenre
            return GameGenre(name: genre.name ?? "", id: Int(genre.id))
        }
        
        self.themes = cdGameItem.themes?.map{
            let theme = $0 as! CDTheme
            return GameTheme(name: theme.name ?? "", id: Int(theme.id))
        }
        if let collection = cdGameItem.collection{
            self.collection = GameCollection(name: collection.name ?? "", id: Int(collection.id), gameIds: collection.gameIds ?? [])
        }
        if let franchise = cdGameItem.franchise{
            self.franchise = GameFranchise(name: franchise.name ?? "", id: Int(franchise.id), gameIds: franchise.gameIds ?? [])
        }
        //TODO: - Videos
    }
}

class GameGenre{
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    var name: String
    var id: Int
}

class GameTheme{
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    var name: String
    var id: Int
}

class GamePlatform{
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    var name: String
    var id: Int
}

class GameFranchise{
    
    init(name: String, id: Int, gameIds: [Int]) {
        self.name = name
        self.id = id
        self.gameIds = gameIds
    }
    
    var name: String
    var id: Int
    var gameIds: [Int]
}

class GameCollection{
    init(name: String, id: Int, gameIds: [Int]) {
        self.name = name
        self.id = id
        self.gameIds = gameIds
    }
    var name: String
    var id: Int
    var gameIds: [Int]
}

struct GameImage{
    var id: Int
    var width: Int
    var height: Int
    var basicUrlStr: String?
    var data: Data?
    var aspect: Double
    
    init(id: Int, width: Int, height: Int, basicUrlStr: String?) {
        self.width = width
        self.height = height
        aspect = Double(height) / Double(width)
        self.basicUrlStr = basicUrlStr
        self.id = id
    }
    
}

struct GameVideo{
    var name: String
    var videoId: String
}

struct GameWebsite {
    var website: Website?
    var url: URL?
    
    init(websiteId: Int?, urlStr: String) {
        if let id = websiteId{
            website = Website(rawValue: id)
        }
        url = URL(string: urlStr)
    }
}



enum GameStatus: Int{
    case released = 0,
         alpha = 2,
         beta = 3,
         earlyAccess = 4,
         offline = 5,
         cancelled = 6,
         rumored = 7
}

enum GameCategory: Int{
    case mainGame = 0,
         dlcAddon = 1,
         expansion = 2,
         bundle = 3,
         standaloneExpansion = 4,
         mod = 5,
         episode = 6,
         season = 7
}

enum GameAgeRating: Int{
    case Three = 1,
         Seven = 2,
         Twelwe = 3,
         Sixteen = 4,
         Eightteen = 5,
         RP = 6,
         EC = 7,
         E = 8,
         E10 = 9,
         T = 10,
         M = 11,
         AO = 12
}

enum GameAgeCategory: Int{
    case ESRB = 1, PEGI = 2
}

enum Website: Int{
    case official = 1,
         wikia = 2,
         wikipedia = 3,
         facebook = 4,
         twitter = 5,
         twitch = 6,
         instagram = 8,
         youtube = 9,
         iphone = 10,
         ipad = 11,
         android = 12,
         steam = 13,
         reddit = 14,
         itch = 15,
         epicgames = 16,
         gog = 17,
         discord = 18
}

enum GameImageSizeKey: String{
    case S90X128 = "cover_small",
         S569X320 = "screenshot_med",
         S264X374 = "cover_big",
         S284X160 = "logo_med",
         S889X500 = "screenshot_big",
         Ss1280X720 = "screenshot_huge",
         S90X90 = "thumb",
         S35X35 = "micro",
         S1280X720 = "720p",
         S1920X1080 = "1080p"
}
