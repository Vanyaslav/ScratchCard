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
}
