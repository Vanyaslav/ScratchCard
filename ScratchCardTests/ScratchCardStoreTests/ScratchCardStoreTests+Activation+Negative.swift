//
//  ScratchCardStoreTests+Activation+Negative.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

class ScratchCardStoreTestsActivationNegative: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var sut: AppStateStore!
    var mockAlertService: NotificationProtocol!
    
    override func setUp() {
        super.setUp()
        mockAlertService = MockNotification()
        sut = AppStateStore(dataService: MockNegativeActivationService(), alertService: mockAlertService)
    }
        
    override func tearDown() {
        sut = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testActivationNegative() throws {
        let expectation = expectation(description: "Activation negative")
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in self.sut.shouldActivate.accept() }
            .store(in: &cancellables)
        
        sut.$stateTitle
            .first { $0 == "Deactivated" }
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertFalse(sut.isDeactivationEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
