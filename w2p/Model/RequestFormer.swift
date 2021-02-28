import Foundation
class RequestFormer{
    var api = "https://api.igdb.com/v4/games/"
    
    static var shared = RequestFormer()
    
    private init() { }
   
    //var api = "http://192.168.1.64:8002/"
    
    func formRequestForSearching(filter: SearchFilter, limit: Int?) -> URLRequest{
        var requestBody = RequestFields.basicFields

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
        /*
        if !filter.gameModes.isEmpty{
            filterComponents.append("game_modes = \(filter.gameModes.toIdArrayString())")
        }
 */
        
        if let aggrRatingUpperBound = filter.ratingUpperBound{
            filterComponents.append("aggregated_rating <= \(aggrRatingUpperBound)")
        }
        
        if let aggrRatingLowerBound = filter.ratingLowerBound{
            filterComponents.append("aggregated_rating >= \(aggrRatingLowerBound)")
        }
            
        if let releaseUpperBound = filter.releaseDateUpperBound{
            filterComponents.append("first_release_date <= \(Int(releaseUpperBound.timeIntervalSince1970))")
        }

        if let releaseLowerBound = filter.releaseDateLowerBound{
            filterComponents.append("first_release_date >= \(Int(releaseLowerBound.timeIntervalSince1970))")
        }

        if !filterComponents.isEmpty {
            requestBody += "where \(filterComponents.joined(separator: "&"));"
        }
        if let searchStr = filter.searchString, !searchStr.isEmpty {
            requestBody += "search \"\(searchStr)\";"
        }
        if let limit = limit, (1...500).contains(limit) {
            requestBody += "limit \(limit);"
        }
        
        print(requestBody)
        
        var request = setupRequest(apiUrl: URL(string: api)!)
        request.httpBody = requestBody.data(using: .utf8)
        return request
    }
    
    func formSizedImageRequest(basicImageUrl: String, sizeKey: GameImageSizeKey) -> URLRequest?{
        
        let components = basicImageUrl.split(separator: "/")
        guard let imageIdComponent = components.last else { return nil}
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "images.igdb.com"
        let sizeComponent = "t_" + sizeKey.rawValue + "_2x"
        let path = "/igdb/image/upload/" + sizeComponent + "/" + imageIdComponent
        urlComponents.path = path
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
    }
    
    func formRequestForSpecificGames(_ gamesIds: [Int]) -> URLRequest {
        var requestBody = RequestFields.basicFields
        requestBody += "where id = \(gamesIds.toIdArrayString(firstBracket: "(", secondBracket: ")"));"
        requestBody += "limit 500;"
        var request = setupRequest(apiUrl: URL(string: api)!)
        request.httpBody = requestBody.data(using: .utf8)
        print(requestBody)
        return request
    }
    
    //Force
    func requestForSimilarGames(for game: Game) -> URLRequest{
        var requestBody = RequestFields.basicFields
        requestBody += "where (genres = [\(game.genres!.first!.id), \(game.genres![1].id)] & "
        
        requestBody += "themes = \(game.themes!.toIdArrayString(firstBracket: "(", secondBracket: ")"))) |"
        requestBody += "id = \(game.similarGames!.toIdArrayString(firstBracket: "(", secondBracket: ")"));"
        
        requestBody += "limit 500;"
        var request = setupRequest(apiUrl: URL(string: api)!)
        print(requestBody)
        request.httpBody = requestBody.data(using: .utf8)
        return request
    }
    
    private func setupRequest(apiUrl: URL) -> URLRequest {
        var request = URLRequest(url: apiUrl)
                request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Client-ID"] = "3u8mueqxsplbm66vhse81c8f65pco1"
        request.allHTTPHeaderFields?["Authorization"] = "Bearer iydn4qze9tz30lelp762msw0tn52oq"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
