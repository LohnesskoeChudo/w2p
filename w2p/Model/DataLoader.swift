import Foundation

class DataLoader{
    
    var urlSession: URLSession
    
    init() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 10
        sessionConfiguration.timeoutIntervalForRequest = 3
        sessionConfiguration.timeoutIntervalForResource = 3
        urlSession = URLSession(configuration: sessionConfiguration)
    }
    
    func load(with request: URLRequest, completion: @escaping (Data?, NetworkError?) -> Void){
        URLSession.shared.dataTask(with: request){
            data, response, error in

            if let capturedData = data{
                completion(capturedData, nil)
            } else {
                completion(nil, .connectionError)
            }
        }.resume()
    }
}



enum NetworkError {
    case connectionError
    case parseError
}
