//
//  DataService.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import Foundation
import Combine

class URLError: Error {}

protocol DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Error>
}

final class DataService: DataServiceProtocol {
    private let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSession = URLSession(configuration: configuration)
    }
    
    func activate(with id: String) -> AnyPublisher<VersionResponse, Error> {
        let queryItems = [URLQueryItem(name: "code", value: id)]
        var urlComponents = URLComponents(string: "https://api.o2.sk/version")
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else {
            return Fail(error: URLError())
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
