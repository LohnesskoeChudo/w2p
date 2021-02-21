import Foundation

struct Game: Decodable{

    var id: Int?
    var name: String?
    var summary: String?
    var storyline: String?
    var aggregatedRating: Double?
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
    
}

struct Genre: Codable{
    var name: String
    var id: Int
}

struct Platform: Codable{
    var id: Int
    var name: String
    
}

struct GameMode: Codable{
    var name: String
}

struct Website: Decodable{
    var id: Int
    var url: String
    var category: Int?
    
}

struct Theme: Codable{
    var id: Int
    var name: String
}

struct Artwork: Codable{
    var id: Int
    var url: String
    var height: Int
    var width: Int
    var animated: Bool?
}

struct Screenshot: Codable{
    var id: Int
    var url: String
    var height: Int
    var width: Int
    var animated: Bool?
}

struct Video: Codable{
    var id: Int
    var name: String
    var videoId: String
    
}

struct Franchise: Codable{
    var id: Int
    var name: String
    var games: [Int]
    
}

struct GameCollection: Codable{
    var id: Int
    var games: [Int]
    var name: String
}

struct AgeRating: Codable{
    var id: Int
    var rating: Int
    var category: Int
    var ratingCoverUrl: String?
}

struct Cover: Codable{
    var id: Int
    var animated: Bool?
    var height: Int
    var width: Int
    var url: String
    
    var aspect: Double{
        Double(height) / Double(width)
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
