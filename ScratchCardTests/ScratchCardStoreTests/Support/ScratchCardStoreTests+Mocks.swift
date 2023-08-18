//
//  ScratchCardStoreTests+Support.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import CombineExt
import Combine

class MockNotification: NotificationProtocol {
    var register = CombineExt.PassthroughRelay<UNUserNotificationCenterDelegate>()
    var showAlert = CombineExt.PassthroughRelay<String>()
}

class MockPositiveActivationService: DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Swift.Error> {
        Just(VersionResponse(ios: "6.11"))
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }
}

class MockNegativeActivationService: DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Swift.Error> {
        Just(VersionResponse(ios: "6.0999"))
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }
}

class MockActivationFailedService: DataServiceProtocol {
    func activate(with id: String) -> AnyPublisher<VersionResponse, Swift.Error> {
        Fail(error: NSError(domain: "test", code: 111) as Swift.Error)
            .eraseToAnyPublisher()
    }
}
