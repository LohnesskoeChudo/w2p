import Foundation
class RequestFormer{
    var api = "https://api.igdb.com/v4/games/"
    
    static var shared = RequestFormer()
    
    private init() { }
   
    //var api = "http://192.168.1.64:8002/"
    
    func formRequestForSearching(filter: SearchFilter, limit: Int?) -> URLRequest{
        var request = URLRequest(url: URL(string: api)!)
        request.httpMethod = "POST"
        
        var requestBody = RequestFields.basicFields

        var filterComponents = [String]()

        if !filter.genres.isEmpty{
            filterComponents.append("genres = \(filter.genres.toIdArrayString())")
        }
        if !filter.themes.isEmpty{
            filterComponents.append("themes = \(filter.themes.toIdArrayString())")
        }
        if !filter.platforms.isEmpty{
            filterComponents.append("platforms = \(filter.platforms.toIdArrayString())")
        }
        if !filter.gameModes.isEmpty{
            filterComponents.append("game_modes = \(filter.gameModes.toIdArrayString())")
        }
        
        if let aggrRatingUpperBound = filter.ratingUpperBound{
            filterComponents.append("aggregated_rating <= \(aggrRatingUpperBound)")
        }
        
        if let aggrRatingLowerBound = filter.ratingLowerBound{
            filterComponents.append("aggregated_rating >= \(aggrRatingLowerBound)")
        }
        
        if filter.onlyNotReleasedYet {
            filterComponents.append("first_release_date >= \(Date().timeIntervalSince1970)")
        } else {
            if let releaseUpperBound = filter.releaseDateUpperBound{
                filterComponents.append("first_release_date <= \(releaseUpperBound.timeIntervalSince1970)")
            }
            
            if let releaseLowerBound = filter.releaseDateLowerBound{
                filterComponents.append("first_release_date >= \(releaseLowerBound.timeIntervalSince1970)")
            }
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
        
        
        
        request.allHTTPHeaderFields?["Client-ID"] = "3u8mueqxsplbm66vhse81c8f65pco1"
        request.allHTTPHeaderFields?["Authorization"] = "Bearer iydn4qze9tz30lelp762msw0tn52oq"
        request.httpBody = requestBody.data(using: .utf8)
        
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
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
    
}
