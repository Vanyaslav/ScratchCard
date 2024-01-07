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
        
        sut.simulateActivation(in: &cancellables)
        
        sut.$state
            .first { $0.title == "Deactivated" }
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertFalse(sut.state.enableScratch)
                XCTAssertTrue(sut.state.enableActivation)
                XCTAssertFalse(sut.state.enableDeactivation)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
