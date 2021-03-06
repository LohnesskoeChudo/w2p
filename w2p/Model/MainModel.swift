import Foundation

class Game: Codable, Equatable{
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int?
    var name: String?
    var summary: String?
    var storyline: String?
    var totalRating: Double?
    var status: Int?
    var category: Int?
    var firstReleaseDate: Date?
    var similarGames: [Int]?
    var cover: Cover?
    var genres: [Genre]?
    var platforms: [Platform]?
    var gameModes: [GameMode]?
    var websites: [Website]?
    var themes: [Theme]?
    var artworks: [Artwork]?
    var screenshots: [Screenshot]?
    var videos: [Video]?
    var franchise: Franchise?
    var collection: GameCollection?
    var ageRatings: [AgeRating]?
    var involvedCompanies: [InvolvedCompany]?
    var gameEngines: [GameEngine]?
    var cacheDate: Date?
    var inFavorites: Bool? = false
}

class Genre: Codable, Hashable, Identifiable{
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        lhs.id == rhs.id
    }
    var name: String?
    var id: Int?
}

class Platform: Codable, Hashable, Identifiable{
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        lhs.id == rhs.id
    }
    var id: Int?
    var name: String?
    
}

class GameMode: Codable, Hashable, Identifiable{
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: GameMode, rhs: GameMode) -> Bool {
        lhs.id == rhs.id
    }
    var id: Int?
    var name: String?
}

class Website: Codable{
    var id: Int?
    var url: String?
    var category: Int?
}

class Theme: Codable, Hashable, Identifiable{
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }
    var id: Int?
    var name: String?
}

class Artwork: Codable, MediaDownloadable{
    var id: Int?
    var url: String?
    var height: Int?
    var width: Int?
    var animated: Bool?
}

class Screenshot: Codable, MediaDownloadable{
    var id: Int?
    var url: String?
    var height: Int?
    var width: Int?
    var animated: Bool?
}

class Video: Codable{
    var id: Int?
    var name: String?
    var videoId: String?
}

class Franchise: Codable{
    var id: Int?
    var name: String?
    var games: [Int]?
}

class GameCollection: Codable{
    var id: Int?
    var games: [Int]?
    var name: String?
}

class AgeRating: Codable{
    var id: Int?
    var rating: Int?
    var category: Int?
    var ratingCoverUrl: String?
}

class Cover: Codable, MediaDownloadable{
    var id: Int?
    var animated: Bool?
    var height: Int?
    var width: Int?
    var url: String?
    
    var aspect: Double?{
        if let h = height, let w = width {
            return Double(h) / Double(w)
        } else {
            return nil
        }
    }
}

class InvolvedCompany: Codable {
    var company: Company?
}

class Company: Codable {
    var id: Int?
    var name: String?
}

class GameEngine: Codable {
    var id: Int?
    var name: String?
}

enum GameStatus: Int{
    case released = 0,
         alpha = 2,
         beta = 3,
         earlyAccess = 4,
         offline = 5,
         cancelled = 6,
         rumored = 7
    
    func toString() -> String {
        switch self {
        case .released:
            return "Released"
        case .alpha:
            return "Alpha"
        case .beta:
            return "Beta"
        case .earlyAccess:
            return "Early access"
        case .offline:
            return "Offline"
        case .cancelled:
            return "Cancelled"
        case .rumored:
            return "rumored"
        }
    }
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
    
    func toString() -> String{
        switch self {
        case .mainGame:
            return "Main game"
        case .dlcAddon:
            return "DLC"
        case .expansion:
            return "Expansion"
        case .bundle:
            return "Bundle"
        case .standaloneExpansion:
            return "Standalone expansion"
        case .mod:
            return "Mod"
        case .episode:
            return "Episode"
        case .season:
            return "Season"
        }
    }
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

enum WebsiteCategory: Int{
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

    var name: String{
        switch self {
        case .official:
            return "Official"
        case .wikia:
            return "Fandom"
        case .wikipedia:
            return "Wikipedia"
        case .facebook:
            return "Facebook"
        case .twitter:
            return "Twitter"
        case .twitch:
            return "Twitch"
        case .instagram:
            return "Instagram"
        case .youtube:
            return "Youtube"
        case .iphone:
            return "Appstore"
        case .ipad:
            return "Appstore"
        case .android:
            return "Playmarket"
        case .steam:
            return "Steam"
        case .reddit:
            return "Reddit"
        case .itch:
            return "Itch"
        case .epicgames:
            return "EpicGames"
        case .gog:
            return "GOG"
        case .discord:
            return "Discord"

        }
    }
}

enum GameImageSizeKey: String , CaseIterable{
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
    
    var measure: Int {
        switch self {
        case .S35X35:
            return 10
        case .S90X90:
            return 20
        case .S90X128:
            return 30
        case .S284X160:
            return 40
        case .S264X374:
            return 50
        case .S569X320:
            return 60
        case .S889X500:
            return 70
        case .Ss1280X720:
            return 80
        case .S1280X720:
            return 90
        case .S1920X1080:
            return 100
        }
    }
}

protocol MediaDownloadable {
    var url: String? {get}
    var id: Int? {get}
}
