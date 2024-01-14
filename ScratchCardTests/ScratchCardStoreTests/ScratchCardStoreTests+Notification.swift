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
    }
        
    override func tearDown() {
        sut = nil
        mockAlertService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testNotificationRegistration() {
        let expectation = expectation(description: #function)
        mockAlertService.register
            .sink {
                XCTAssert($0 is AppStateStore)
                expectation.fulfill()
            }.store(in: &cancellables)
        _ = AppStateStore(alertService: mockAlertService)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testTriggeredNotificationNegative() throws {
        let expectation = expectation(description: #function)
        sut = AppStateStore(dataService: MockNegativeActivationService(), alertService: mockAlertService)
        sut.simulateActivation(in: &cancellables)
        
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
    
    func testTriggeredNotificationNetworkError() throws {
        let expectation = expectation(description: #function)
        sut = AppStateStore(dataService: MockActivationFailedService(), alertService: mockAlertService)
        // when
        sut.simulateActivation(in: &cancellables)
        // then
        mockAlertService.showAlert
            .sink {
                XCTAssertEqual($0, "The operation couldn’t be completed. (test error 111.)")
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
