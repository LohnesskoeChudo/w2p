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
        if let sort = gameRequest.sorting {
            body += sort
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
        
        print(body)
        
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
    var sorting: String?
    
    var limit: Int? {
        didSet {
            if let limit = limit, (1...500).contains(limit) {
                limitStr = "limit \(limit);"
            }
        }
    }
    var limitStr: String?
    
    static private func addCommonFilters(to filterStr: String) -> String{
        return "where \(filterStr) & themes != (42);"
    }
    
    static func formRequestItemForSearching(filter: SearchFilter, limit: Int?) -> GameApiRequestItem {
        
        let gameRequestItem = GameApiRequestItem()
            
        gameRequestItem.limit = limit
        if let searchStr = filter.searchString, !searchStr.isEmpty {
            gameRequestItem.search = "search \"\(searchStr)\";"
        }
        gameRequestItem.offset = 0
        gameRequestItem.fields = basicFields
        if let basicFilterStr = formSearchingFilters(with: filter) {
            let finalFilterStr = addCommonFilters(to: basicFilterStr)
            gameRequestItem.filter = finalFilterStr
        }
        if filter.isDefault {
            gameRequestItem.sorting = "sort total_rating_count desc;"
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
    
    static func formRequestItemForNewAvailableGames() -> GameApiRequestItem {
        let gameRequestItem = GameApiRequestItem()
        gameRequestItem.offset = 0
        gameRequestItem.limit = 500
        gameRequestItem.fields = basicFields
        
        let nowStamp = Int(Date(timeIntervalSinceNow: 0).timeIntervalSince1970)
        
        let monthInSeconds = 30 * 24 * 60 * 60
        
        var alreadyAvailableFilter = "(first_release_date >= \(nowStamp - monthInSeconds) & (first_release_date <= \(nowStamp) | (first_release_date >= \(nowStamp) & status = (3,4))))"
        
        alreadyAvailableFilter = "(\(alreadyAvailableFilter) & hypes != null)"
        

        let filter = addCommonFilters(to: alreadyAvailableFilter)
        gameRequestItem.filter = filter
        
        gameRequestItem.sorting = "sort hypes desc;"
        
        return gameRequestItem
    }
    
    static func formRequestItemForSimilarGames(with game: Game) -> GameApiRequestItem? {
        
        var filterComponents = [String]()
        let genresCriteria = genresCriteriaForSimilarGame(with: game)
        let themeCriteria = themesCriteriaForSimilarGame(with: game)
        
        if genresCriteria == nil && game.similarGames == nil {
            return nil
        }
            
        if let genresCriteria = genresCriteria {
            filterComponents.append(genresCriteria)
        }
        if let themeCriteria = themeCriteria {
            filterComponents.append(themeCriteria)
        }
        
        var filter = ""
        filter = filterComponents.joined(separator: "&")
        if let similarGames = game.similarGames {
            filter = "(\(filter)) | id = \(similarGames.toIdArrayString(firstBracket: "(", secondBracket: ")"))"
        }
        

        let gameRequestItem = GameApiRequestItem()
        gameRequestItem.fields = basicFields
        gameRequestItem.limit = 500
        gameRequestItem.offset = 0
        gameRequestItem.filter = addCommonFilters(to: filter)

        return gameRequestItem
    }
    
    static func similarGamesRequestAvailableFor(game: Game) -> Bool{
        if formRequestItemForSimilarGames(with: game) != nil {
            return true
        } else {
            return false
        }
    }
    
    static private func genresCriteriaForSimilarGame(with game: Game) -> String?{
        if var genres = game.genres, genres.count != 0{
            
            
            if genres.count > 6 {
                genres.shuffle()
                genres = genres.suffix(6)
            }
            
            
            var genresCombinations = [[Genre]]()
            if genres.count > 3 {
                genresCombinations += combinations(collection: genres, k: 3) ?? []
                genresCombinations += combinations(collection: genres, k: 4) ?? []
            } else if genres.count > 2 {
                genresCombinations += combinations(collection: genres, k: 3) ?? []
                genresCombinations += combinations(collection: genres, k: 2) ?? []
            } else {
                genresCombinations += combinations(collection: genres, k: genres.count) ?? []
            }
            var temp = [String]()
            for genreCombination in genresCombinations {
                temp.append("genres = \(genreCombination.toIdArrayString(firstBracket: "{", secondBracket: "}"))")
            }
            return "(\(temp.joined(separator: "|")))"
        }
        return nil
    }
    
    static private func themesCriteriaForSimilarGame(with game: Game) -> String?{
        if var themes = game.themes, themes.count != 0{
            
            if themes.count > 6 {
                themes.shuffle()
                themes = themes.suffix(6)
            }
            
            var themesCombinations = [[Theme]]()
            if themes.count > 2 {
                themesCombinations += combinations(collection: themes, k: 2) ?? []
            } else {
                themesCombinations += combinations(collection: themes, k: themes.count) ?? []
            }
            var temp = [String]()
            for themeCombination in themesCombinations {
                temp.append("themes = \(themeCombination.toIdArrayString(firstBracket: "[", secondBracket: "]"))")
            }
            return "(\(temp.joined(separator: "|")))"
        }
        return nil
    }
    
    static private func formSearchingFilters(with filter: SearchFilter) -> String?{
        
        if filter.isDefault {
            return "(cover != null & total_rating_count != null)"
        }
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
        if filter.excludeEmptyGames == true {
            filterComponents.append("(cover != null | summary != null | storyline != null)")
        }
        if !filterComponents.isEmpty {
             return "(\(filterComponents.joined(separator: "&")))"
        }
        return nil
    }
}
