import Foundation

protocol PJsonLoader {
    func load<T>(request: URLRequest, completion: @escaping (T?, NetworkError?) -> Void) where T: Decodable
}

final class JsonLoader: PJsonLoader {
    
    private var dataLoader = Resolver.shared.container.resolve(PDataLoader.self)!
    private var decoder: JSONDecoder

    init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder
    }
    
    func load<T>(request: URLRequest, completion: @escaping (T?, NetworkError?) -> Void) where T:Decodable {
        dataLoader.load(with: request) {
            (data: Data?, networkError: NetworkError?) -> Void in
            if let data = data{
                if let jsonData = try? self.decoder.decode(T.self, from: data) {
                    completion(jsonData, nil)
                } else {
                    completion(nil, .parseError)
                }
                return
            } else {
                completion(nil, .connectionError)
            }
        }
    }
}
