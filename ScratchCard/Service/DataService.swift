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
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSession = URLSession(configuration: configuration)
    }
    
    func activate(with id: String) -> AnyPublisher<VersionResponse, Swift.Error> {
        let queryItems = [URLQueryItem(name: "code", value: id)]
        var urlComponents = URLComponents(string: "https://api.o2.sk/version")
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else {
            return Fail(error: Error.URL)
                .eraseToAnyPublisher()
        }
        return urlSession
            .dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap { $0.data }
            .decode(type: VersionResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
