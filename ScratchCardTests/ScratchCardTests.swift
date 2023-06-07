//
//  ScratchCardTests.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 06/05/2023.
//

import XCTest
@testable import ScratchCard
import Combine
import CombineExt

final class ScratchCardStoreTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func testInitialState() throws {
        let sut = AppStateStore(service: MockPositiveActivationService())
        XCTAssertEqual(sut.stateTitle, "Unscratched")
        XCTAssertTrue(sut.isScratchEnabled)
        XCTAssertFalse(sut.isActivationEnabled)
        XCTAssertFalse(sut.isDeactivationEnabled)
        XCTAssertNil(sut.generatedCode)
    }
    
    func testCancelScratching() throws {
        let expectation = expectation(description: "Cancel scratching")
        let sut = AppStateStore(service: MockPositiveActivationService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertTrue(sut.isScratchEnabled)
            XCTAssertFalse(sut.isActivationEnabled)
            XCTAssertFalse(sut.isDeactivationEnabled)
            sut.cancelGenerateCode.accept()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertTrue(sut.isScratchEnabled)
            XCTAssertFalse(sut.isActivationEnabled)
            XCTAssertFalse(sut.isDeactivationEnabled)
            expectation.fulfill()
        }
                                      
        wait(for: [expectation], timeout: 5)
    }
    
    func testScratching() throws {
        let expectation = expectation(description: "Scratch code")
        let mockAlertService = MockNotification()
        let sut = AppStateStore(service: MockActivationFailedService(), alertService: mockAlertService)
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertFalse(sut.isDeactivationEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                XCTAssertNotNil(sut.generatedCode)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }

    func testActivationFailure() throws {
        let expectation = expectation(description: "Activation failure")
        let mockAlertService = MockNotification()
        let sut = AppStateStore(service: MockActivationFailedService(), alertService: mockAlertService)
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in sut.shouldActivate.accept() }
            .store(in: &cancellables)
        
        mockAlertService.showAlert
            .sink {
                XCTAssertEqual($0, "The operation couldn’t be completed. (test error 111.)")
                XCTAssertEqual(sut.stateTitle, "Scratched")
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                XCTAssertFalse(sut.isDeactivationEnabled)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testActivationPositive() throws {
        let expectation = expectation(description: "Activation positive")
        let sut = AppStateStore(service: MockPositiveActivationService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in sut.shouldActivate.accept() }
            .store(in: &cancellables)
        
        sut.$stateTitle
            .first { $0 == "Activated" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                XCTAssertTrue(sut.isDeactivationEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testNotificationRegistration() {
        let expectation = expectation(description: "Notification registration")
        let mockAlertService = MockNotification()
        mockAlertService.register
            .sink {
                XCTAssert($0 is AppStateStore)
                expectation.fulfill()
            }.store(in: &cancellables)
        _ = AppStateStore(alertService: mockAlertService)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testActivationNegative() throws {
        let expectation = expectation(description: "Activation negative")
        let mockAlertService = MockNotification()
        let sut = AppStateStore(service: MockNegativeActivationService(), alertService: mockAlertService)
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in sut.shouldActivate.accept() }
            .store(in: &cancellables)
        
        sut.$stateTitle
            .first { $0 == "Deactivated" }
            .sink { _ in
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertFalse(sut.isDeactivationEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockAlertService.showAlert
            .sink { XCTAssertEqual($0, "Activation was not successful!") }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}

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
