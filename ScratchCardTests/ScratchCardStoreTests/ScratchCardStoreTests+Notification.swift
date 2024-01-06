//
//  ScratchCardStoreTests+Notification.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

class ScratchCardStoreTestsNotification: XCTestCase {
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
    
    func testNotificationRegistration() {
        let expectation = expectation(description: "Notification registration")
        mockAlertService.register
            .sink {
                XCTAssert($0 is AppStateStore)
                expectation.fulfill()
            }.store(in: &cancellables)
        _ = AppStateStore(alertService: mockAlertService)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testTriggeredNotificationNegative() throws {
        let expectation = expectation(description: "Notification triggering - negative response")
        sut.send.accept(.generateCode)
        
        sut.$state
            .first { $0.title == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .map { _ in .shouldActivate }
            .sink(receiveValue: sut.send.accept)
            .store(in: &cancellables)
        
        mockAlertService.showAlert
            .sink { XCTAssertEqual($0, "Activation was not successful!") }
            .store(in: &cancellables)
        
        sut.$state
            .first { $0.title == "Deactivated" }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
