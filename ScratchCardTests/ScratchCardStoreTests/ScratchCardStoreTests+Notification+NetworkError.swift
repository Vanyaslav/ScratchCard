//
//  ScratchCardStoreTests+Notification+NetworkError.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

class ScratchCardStoreTestsNotificationNetworkError: XCTestCase {
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
    
    func testTriggeredNotificationNetworkError() throws {
        let expectation = expectation(description: "Notification triggering - network error")
        sut.send.accept(.generateCode) 
        // when
        sut.$state
            .first { $0.title == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .map { _ in .shouldActivate }
            .sink(receiveValue: sut.send.accept)
            .store(in: &cancellables)
        // then
        mockAlertService.showAlert
            .sink {
                XCTAssertEqual($0, "The operation couldn’t be completed. (test error 111.)")
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
