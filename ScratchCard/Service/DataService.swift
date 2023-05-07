//
//  DataService.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import Foundation
import Combine

protocol DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Error>
}

class URLError: Error {}

class DataService: DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Error> {
        let queryItems = [URLQueryItem(name: "code", value: id)]
        var urlComponents = URLComponents(string: "https://api.o2.sk/version")
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else {
            return Fail(error: URLError())
                .eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap { $0.data }
            .decode(type: VersionResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
