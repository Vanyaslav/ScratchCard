//
//  ScratchCardTests.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 06/05/2023.
//

import XCTest
@testable import ScratchCard
import Combine

final class ScratchCardStoreTests: XCTestCase {
    func testInitialState() throws {
        let sut = AppStateStore(service: MockPositiveActivationService())
        XCTAssertEqual(sut.stateTitle, "Unscratched")
        XCTAssertTrue(sut.isScratchEnabled)
        XCTAssertFalse(sut.isActivationEnabled)
        XCTAssertNil(sut.generatedCode)
        XCTAssertNil(sut.showError)
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
            XCTAssertNil(sut.showError)
            sut.cancelGenerateCode.accept()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertTrue(sut.isScratchEnabled)
            XCTAssertFalse(sut.isActivationEnabled)
            XCTAssertNil(sut.showError)
            expectation.fulfill()
        }
                                      
        wait(for: [expectation], timeout: 5)
    }

    func testScratchingAndActivationFailure() throws {
        let expectation = expectation(description: "Activation failure")
        let sut = AppStateStore(service: MockActivationFailedService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertTrue(sut.isScratchEnabled)
            XCTAssertFalse(sut.isActivationEnabled)
            XCTAssertNil(sut.showError)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            XCTAssertEqual(sut.stateTitle, "Scratched")
            XCTAssertFalse(sut.isScratchEnabled)
            XCTAssertTrue(sut.isActivationEnabled)
            XCTAssertNil(sut.showError)
            sut.shouldActivate.accept()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            XCTAssertEqual(sut.stateTitle, "Scratched")
            XCTAssertFalse(sut.isScratchEnabled)
            XCTAssertTrue(sut.isActivationEnabled)
            XCTAssertEqual(sut.showError, "The operation couldn’t be completed. (test error 111.)")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testActivationPositive() throws {
        let expectation = expectation(description: "Activation positive")
        let sut = AppStateStore(service: MockPositiveActivationService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            sut.shouldActivate.accept()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(sut.stateTitle, "Activated")
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                XCTAssertNil(sut.showError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3)
    }
    
    func testActivationNegative() throws {
        let expectation = expectation(description: "Activation negative")
        let sut = AppStateStore(service: MockNegativeActivationService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            XCTAssertEqual(sut.stateTitle, "Scratched")
            XCTAssertFalse(sut.isScratchEnabled)
            XCTAssertTrue(sut.isActivationEnabled)
            XCTAssertNil(sut.showError)
            sut.shouldActivate.accept()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(sut.stateTitle, "Deactivated")
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                XCTAssertEqual(sut.showError, "Activation was not successful!")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3)
    }
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
