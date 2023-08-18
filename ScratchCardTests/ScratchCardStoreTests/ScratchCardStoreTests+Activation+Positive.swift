//
//  ScratchCardStoreTests+Activation+Positive.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

class ScratchCardStoreTestsActivationPositive: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var sut: AppStateStore!
    
    override func setUp() {
        super.setUp()
        sut = AppStateStore(dataService: MockPositiveActivationService())
    }
        
    override func tearDown() {
        sut = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testActivationPositive() throws {
        let expectation = expectation(description: "Activation positive")
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in self.sut.shouldActivate.accept() }
            .store(in: &cancellables)
        
        sut.$stateTitle
            .first { $0 == "Activated" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertFalse(sut.isActivationEnabled)
                XCTAssertTrue(sut.isDeactivationEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
}
