import Foundation
class RequestFormer{
    var api = URL(string: "https://api.igdb.com/v4/games/")!
    
    static var shared = RequestFormer()
    private init() { }
   
    //var api = "http://192.168.1.64:8002/"
    
    
    func formRequestForCover(with cover: Cover, sizeKey: GameImageSizeKey) -> URLRequest?{
        guard let imageIdComponent = getImageIdComponent(for: cover) else {return nil}
        var urlComponents = configuredComponentsForRequest()
        let path = pathForImageRequest(sizeKey: .S264X374, idComponent: imageIdComponent)
        urlComponents.path = path
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
    }

    func formRequestForMediaStaticContent(for media: MediaDownloadable, sizeKey: GameImageSizeKey) -> URLRequest?{
        guard let imageIdComponent = getImageIdComponent(for: media) else {return nil}
        var urlComponents = configuredComponentsForRequest()
        let path = pathForImageRequest(sizeKey: sizeKey, idComponent: imageIdComponent)
        urlComponents.path = path
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
    }
    
    func formRequest(with gameRequest: GameApiRequestItem) -> URLRequest {
        var request = setupRequest()
        var body = ""
        if let fields = gameRequest.fields {
            body += fields
        }
        if let search = gameRequest.search {
            body += search
        }
        if let filter = gameRequest.filter {
            body += filter
        }
        if let offset = gameRequest.offsetStr {
            body += offset
        }
        if let limit = gameRequest.limitStr {
            body += limit
        }
        request.httpBody = body.data(using: .utf8)
        return request
    }
    
    
    
    private func configuredComponentsForRequest() -> URLComponents{
            var urlComponents = URLComponents()
            urlComponents.scheme = "http"
            urlComponents.host = "images.igdb.com"
        return urlComponents
    }
    
    private func pathForImageRequest(sizeKey: GameImageSizeKey, idComponent: String) -> String {
        let sizeComponent = "t_" + sizeKey.rawValue + "_2x"
        let path = "/igdb/image/upload/" + sizeComponent + "/" + idComponent
        return path
    }
    
    private func setupRequest() -> URLRequest {
        var request = URLRequest(url: api)
                request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Client-ID"] = "3u8mueqxsplbm66vhse81c8f65pco1"
        request.allHTTPHeaderFields?["Authorization"] = "Bearer iydn4qze9tz30lelp762msw0tn52oq"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }

    private func getImageIdComponent(for media: MediaDownloadable) -> String?{
        guard let basicImageUrl = media.url else { return nil }
        let components = basicImageUrl.split(separator: "/")
        if let idComponent = components.last{
            return String(idComponent)
        } else {
            return nil
        }
    }
}

class GameApiRequestItem {
    var offset: Int? {
        didSet{
            if let offset = offset, offset >= 0{
                offsetStr = "offset \(offset);"
            }
        }
    }
    
    static var basicFields =
    """
        fields
        name,
        category,
        summary,
        storyline,
        total_rating,
        status,
        first_release_date,
        similar_games,
        cover.animated, cover.height, cover.width, cover.url,
        genres.name,
        platforms.name,
        game_modes.name,
        websites.url, websites.category,
        themes.name,
        artworks.animated, artworks.height, artworks.width, artworks.url,
        screenshots.animated, screenshots.height, screenshots.width, screenshots.url,
        videos.name, videos.video_id,
        franchise.games, franchise.name,
        collection.games, collection.name,
        age_ratings.category, age_ratings.rating, age_ratings.rating_cover_url,
        involved_companies.company.name, game_engines.name;

    """
    
    var offsetStr: String?
    var filter: String?
    var search: String?
    var fields: String?
    
    var limit: Int? {
        didSet {
            if let limit = limit, (1...500).contains(limit) {
                limitStr = "limit \(limit);"
            }
        }
    }
    var limitStr: String?
    
    static func formRequestItemForSearching(filter: SearchFilter, limit: Int?) -> GameApiRequestItem {
        
        let gameRequestItem = GameApiRequestItem()
            
        gameRequestItem.limit = limit
        gameRequestItem.filter = formSearchingFilterString(with: filter)
        gameRequestItem.offset = 0
        gameRequestItem.fields = basicFields
        if let searchStr = filter.searchString, !searchStr.isEmpty {
            gameRequestItem.search = "search \"\(searchStr)\";"
        }
        
        return gameRequestItem

    }
    
    static func formRequestItemForSpecificGames(gamesIds: [Int]) -> GameApiRequestItem?{
        if gamesIds.count == 0 {return nil}
        let gameRequestItem = GameApiRequestItem()
        gameRequestItem.offset = 0
        gameRequestItem.fields = basicFields
        gameRequestItem.limit = 500
        gameRequestItem.filter = "where id = \(gamesIds.toIdArrayString(firstBracket: "(", secondBracket: ")"));"
        return gameRequestItem
    }
    
    static func formRequestItemForSimilarGames(with game: Game) -> GameApiRequestItem? {
        
        guard let genresCriteria = genresCriteriaForSimilarGame(with: game) else {return nil}
        
        let gameRequestItem = GameApiRequestItem()
        var filterComponents = [String]()
        filterComponents.append(genresCriteria)
        if let themeCriteria = themesCriteriaForSimilarGame(with: game) {
            filterComponents.append(themeCriteria)
        }
        
        gameRequestItem.filter = "where \(filterComponents.joined(separator: "&"));"
        gameRequestItem.fields = basicFields
        gameRequestItem.limit = 500
        gameRequestItem.offset = 0
        
        return gameRequestItem
        
    }
    
    static private func genresCriteriaForSimilarGame(with game: Game) -> String?{
        if let genres = game.genres, genres.count != 0{
            let genreSets = genres.growingOrderedSubarrays()
            if genreSets.count == 0 {
                return nil
            } else {
                return "genres = \(genreSets[min(3,genreSets.count-1)].toIdArrayString(firstBracket: "[", secondBracket: "]"))"
            }
        }
        return nil
    }
    
    static private func themesCriteriaForSimilarGame(with game: Game) -> String?{
        if let themes = game.themes, themes.count != 0{
            return "themes = \(themes.toIdArrayString(firstBracket: "(", secondBracket: ")"))"
        }
        return nil
    }
    
    
    
    
    static private func formSearchingFilterString(with filter: SearchFilter) -> String?{
        
        var filterComponents = [String]()
        
        if !filter.genres.isEmpty{
            filterComponents.append("genres = \(filter.genres.toIdArrayString(firstBracket: "[", secondBracket: "]"))")
        }
        if !filter.themes.isEmpty{
            filterComponents.append("themes = \(filter.themes.toIdArrayString(firstBracket: "[", secondBracket: "]"))")
        }
        if !filter.platforms.isEmpty{
            filterComponents.append("platforms = \(filter.platforms.toIdArrayString(firstBracket: "[", secondBracket: "]"))")
        }

        if let aggrRatingUpperBound = filter.ratingUpperBound{
            filterComponents.append("total_rating <= \(aggrRatingUpperBound)")
        }
        
        if let aggrRatingLowerBound = filter.ratingLowerBound{
            filterComponents.append("total_rating >= \(aggrRatingLowerBound)")
        }
            
        if let releaseUpperBound = filter.releaseDateUpperBound{
            filterComponents.append("total_rating <= \(Int(releaseUpperBound.timeIntervalSince1970))")
        }

        if let releaseLowerBound = filter.releaseDateLowerBound{
            filterComponents.append("first_release_date >= \(Int(releaseLowerBound.timeIntervalSince1970))")
        }

        if !filterComponents.isEmpty {
             return "where \(filterComponents.joined(separator: "&"));"
        }
        
        return nil
    }
}
