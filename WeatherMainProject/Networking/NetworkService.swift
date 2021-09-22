//
//  NetworkService.swift
//  Papa Johns Codes
//
//  Created by Aleksei Elin on 19.09.2019.
//  Copyright © 2019 Aleksei Elin. All rights reserved.
//

import Foundation

protocol Networking {
    func request(type: NetworkService.RequestType, urlString: String, parameters: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

class NetworkService: Networking {
    
    enum RequestType: String {
        case POST
        case GET
        case PUT
        case DELETE
    }
    

    func request(type: RequestType, urlString: String, parameters: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        guard var components = URLComponents(string: urlString) else { return }

        components.queryItems = parameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value as? String) })

        guard let url = components.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue

        let task = createDataTask(from: request, completion: completion)
        task.resume()

    }
    
     
    private func createDataTask(from requst: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: requst, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        })
    }
}
