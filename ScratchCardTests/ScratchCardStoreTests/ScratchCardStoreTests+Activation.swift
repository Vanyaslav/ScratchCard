//
//  ScratchCardStoreTests+Activation+Positive.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

extension AppStateStore {
    func simulateActivation(in cancellables: inout Set<AnyCancellable>) {
        send.accept(.generateCode)
        $state
            .first { $0.title == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .map { _ in .shouldActivate }
            .sink(receiveValue: send.accept)
            .store(in: &cancellables)
    }
}

class ScratchCardStoreTestsActivationPositive: XCTestCase {
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
    
    func testActivationPositive() throws {
        let expectation = expectation(description: "Activation positive")

        sut = AppStateStore(dataService: MockPositiveActivationService())
        
        sut.simulateActivation(in: &cancellables)
        
        sut.$state
            .first { $0.title == "Activated" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertFalse(sut.state.enableScratch)
                XCTAssertFalse(sut.state.enableActivation)
                XCTAssertTrue(sut.state.enableDeactivation)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testActivationNegative() throws {
        let expectation = expectation(description: "Activation negative")
        
        sut = AppStateStore(dataService: MockNegativeActivationService(), alertService: mockAlertService)
        
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
    
    func testActivationFailure() throws {
        let expectation = expectation(description: "Activation error")

        sut = AppStateStore(dataService: MockActivationFailedService(), alertService: mockAlertService)
        
        sut.simulateActivation(in: &cancellables)
        
        mockAlertService.showAlert
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertEqual(sut.state.title, "Scratched")
                XCTAssertFalse(sut.state.enableScratch)
                XCTAssertTrue(sut.state.enableActivation)
                XCTAssertFalse(sut.state.enableDeactivation)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
    }
}
