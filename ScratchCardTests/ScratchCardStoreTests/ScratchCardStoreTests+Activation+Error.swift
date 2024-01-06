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


class ScratchCardStoreTestsActivationError: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var sut: AppStateStore!
    var mockAlertService: NotificationProtocol!
    
    override func setUp() {
        super.setUp()
        mockAlertService = MockNotification()
        sut = AppStateStore(dataService: MockActivationFailedService(), alertService: mockAlertService)
    }
        
    override func tearDown() {
        sut = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testActivationFailure() throws {
        let expectation = expectation(description: "Activation error")
        sut.send.accept(.generateCode)
        
        sut.$state
            .first { $0.title == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in self.sut.send.accept(.shouldActivate) }
            .store(in: &cancellables)
        
        mockAlertService.showAlert
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertEqual(sut.state.title, "Scratched")
                XCTAssertFalse(sut.state.enableScratch)
                XCTAssertTrue(sut.state.enableActivation)
                XCTAssertFalse(sut.state.enableDeactivation)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
}
