import Foundation
class RequestFormer{
    
    var apiStr = "https://api.igdb.com/v4/games/"
    lazy var api = URL(string: apiStr)!
    
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
    
    func formRequestForTotalGameCount() -> URLRequest{
        let gameCountApi = URL(string: apiStr + "count/")!
        let request = setupRequest(url: gameCountApi)
        return request
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
        var request = setupRequest(url: api)
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
    
    private func setupRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
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


