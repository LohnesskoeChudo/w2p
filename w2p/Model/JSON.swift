import Foundation

struct JSONGame: Codable{
    var id: Int
    var name: String
    var summary: String?
    var storyline: String?
    var aggregatedRating: Double?
    var status: Int?
    var category: Int?
    var firstReleaseDate: Date?
    var similarGames: [Int]?
    var cover: JSONCover?
    var genres: [JSONGenre]?
    var platforms: [JSONPlatform]?
    var gameModes: [JSONGameMode]?
    var websites: [JSONWebsite]?
    var themes: [JSONTheme]?
    var artworks: [JSONArtwork]?
    var screenshots: [JSONScreenshot]?
    var videos: [JSONVideo]?
    var franchise: JSONFranchise?
    var collection: JSONCollection?
    var ageRatings: [JSONAgeRating]?
    
}

struct JSONGenre: Codable{
    
    var name: String
    var id: Int
}

struct JSONPlatform: Codable{
    
    var id: Int
    var name: String
    
}

struct JSONGameMode: Codable{
    var id: Int
    var name: String
}

struct JSONWebsite: Codable{
    var id: Int
    var url: String
    var category: Int?
}

struct JSONTheme: Codable{
    var id: Int
    var name: String
    
}

struct JSONArtwork: Codable{
    var id: Int
    var url: String
    var height: Int
    var width: Int
    var animated: Bool?
}

struct JSONScreenshot: Codable{
    var id: Int
    var url: String
    var height: Int
    var width: Int
    var animated: Bool?

}

struct JSONVideo: Codable{
    var id: Int
    var name: String
    var videoId: String
    
}

struct JSONFranchise: Codable{
    var id: Int
    var name: String
    var games: [Int]
    
}

struct JSONCollection: Codable{
    var id: Int
    var games: [Int]
    var name: String
}

struct JSONAgeRating: Codable{
    var id: Int
    var rating: Int
    var category: Int
    var ratingCoverUrl: String?
}

struct JSONCover: Codable{
    var id: Int
    var animated: Bool?
    var height: Int
    var width: Int
    var url: String
}
