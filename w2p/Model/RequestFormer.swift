import Foundation
class RequestFormer{
    var api = "https://api.igdb.com/v4/games/"
    
    static var shared = RequestFormer()
    
    private init() { }
   
    //var api = "http://192.168.1.64:8002/"
    var basicFields = """
        fields
        name,
        category,
        summary,
        storyline,
        aggregated_rating,
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
        age_ratings.category, age_ratings.rating, age_ratings.rating_cover_url;

        where aggregated_rating < 80;

        limit 100;
        """
    
    func formRequestForSearching(filter: SearchFilter) -> URLRequest{
        var request = URLRequest(url: URL(string: api)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Client-ID"] = "3u8mueqxsplbm66vhse81c8f65pco1"
        request.allHTTPHeaderFields?["Authorization"] = "Bearer iydn4qze9tz30lelp762msw0tn52oq"
        request.httpBody = basicFields.data(using: .utf8)
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
