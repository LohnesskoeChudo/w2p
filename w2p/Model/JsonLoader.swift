import Foundation

class JsonLoader{
    
    private var dataLoader: DataLoader
    var decoder: JSONDecoder

    init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder
        self.dataLoader = DataLoader()
    }
    
    func load<T>(request: URLRequest, completion: @escaping (T?, NetworkError?) -> Void) where T:Decodable{
        
        let parseData = {
            (data: Data?, networkError: NetworkError?) -> Void in
            if let data = data{
                if let jsonData = try? self.decoder.decode(T.self, from: data){
                    completion(jsonData, nil)
                } else {
                    completion(nil, .parseError)
                }
            }
        }
        dataLoader.load(with: request, completion: parseData)
    }
}
