//
//  DataService.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import Foundation
import Combine

struct VersionResponse: Decodable {
    let ios: String?
}

enum Error: Swift.Error {
    case URL
}

protocol DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Swift.Error>
}

final class DataService: DataServiceProtocol {
    private let urlSession: URLSession
    private let backgroundQueue = DispatchQueue(label: "dummy.network.queue", qos: .background)
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        urlSession = URLSession(configuration: configuration)
    }
    
    func activate(with id: String) -> AnyPublisher<VersionResponse, Swift.Error> {
//        let queryItems = [URLQueryItem(name: "code", value: id)]
//        var urlComponents = URLComponents(string: "https://dummyServis.com/version")
//        urlComponents?.queryItems = queryItems
//        guard let url = urlComponents?.url else {
//            return Fail(error: Error.URL)
//                .eraseToAnyPublisher()
//        }
//        return urlSession
//            .dataTaskPublisher(for: url)
//            .tryMap { $0.data }
//            .decode(type: VersionResponse.self, decoder: JSONDecoder())
//            .eraseToAnyPublisher()

//  Data alternative
        Just(VersionResponse(ios: ["6.1","6.2","5.3","9.4"].randomElement()))
            .delay(for: 2, scheduler: backgroundQueue)
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
        
//  Error alternative
//        Fail<VersionResponse, Swift.Error>(error: NSError(domain: "Simulated network error", code: 666))
//            .delay(for: 2, scheduler: backgroundQueue)
//            .eraseToAnyPublisher()
    }
}
