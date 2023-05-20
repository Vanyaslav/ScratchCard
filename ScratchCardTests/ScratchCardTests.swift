//
//  ScratchCardTests.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 06/05/2023.
//

import XCTest
@testable import ScratchCard
import Combine

final class ScratchCardTests: XCTestCase {    
    func testCancelScratching() throws {
        let expectation = expectation(description: "Cancel scratching")
        let sut = AppStateStore(service: MockPositiveActivationService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssert(sut.generatedCode == nil)
            sut.cancelGenerateCode.accept()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssert(sut.generatedCode == nil)
            expectation.fulfill()
        }
                                      
        wait(for: [expectation], timeout: 5)
    }

    func testScraichingAndActivationFailure() throws {
        let expectation = expectation(description: "Activation failure")
        let sut = AppStateStore(service: MockActivationFailedService())
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertNil(sut.generatedCode)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            XCTAssertEqual(sut.stateTitle, "Scratched")
            XCTAssertNotNil(sut.generatedCode)
            sut.shouldActivate.accept()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            XCTAssertEqual(sut.stateTitle, "Scratched")
            // XCTAssertEqual(sut.showError, "The operation couldn’t be completed. (test error 111.)")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testActivationPositive() throws {
        let expectation = expectation(description: "Activation positive")
        let sut = AppStateStore(service: MockPositiveActivationService(), initialCode: "hdghsghshsgs")
        sut.shouldActivate.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(sut.stateTitle, "Activated")
            // XCTAssertEqual(sut.showError, nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
    
    func testActivationNegative() throws {
        let expectation = expectation(description: "Activation negative")
        let sut = AppStateStore(service: MockNegativeActivationService(), initialCode: "hdghsghshsgs")
        sut.shouldActivate.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            // XCTAssertEqual(sut.showError, "Activation was not successful!")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
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
