import Foundation

class DataLoader{
    
    func load(with request: URLRequest, completion: @escaping (Data?, NetworkError?) -> Void){
        URLSession.shared.dataTask(with: request){
            data, response, error in

            if let capturedData = data{
                completion(capturedData, nil)
            } else {
                completion(nil, .requestError)
            }
        }.resume()
    }
}

enum NetworkError {
    case requestError
    case parseError
}
