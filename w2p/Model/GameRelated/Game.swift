import CoreData

class Game: NSManagedObject, Codable{
    
    enum CodingKeys: CodingKey{
        case id, name, status, storyline, summary, category, aggregatedRating, firstReleaseDate, websites, videos, themes, similarGames, screenshots, platforms, genres, gameModes, franchise, cover, collection, arworks, ageRating
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else { throw DecoderConfigurationError.missingManagedObjectContext }
        
        self.init(context: moc)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.status = try container.decode(Int64.self, forKey: .status)
        self.storyline = try container.decode(String.self, forKey: .storyline)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.category = try container.decode(Int64.self, forKey: .category)
        self.aggregatedRating = try container.decode(Double.self, forKey: .aggregatedRating)
        self.firstReleaseDate = try container.decodeIfPresent(Date.self, forKey: .firstReleaseDate)
        
    }
}

enum DecoderConfigurationError: Error{
    case missingManagedObjectContext
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
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
