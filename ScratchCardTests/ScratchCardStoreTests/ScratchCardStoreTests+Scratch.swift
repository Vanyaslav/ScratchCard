//
//  ScratchCardStoreTests+Scratch.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

class ScratchCardStoreTestsScratch: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var sut: AppStateStore!
    
    override func setUp() {
        super.setUp()
        sut = AppStateStore()
    }
        
    override func tearDown() {
        sut = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testCancelScratching() throws {
        let expectation = expectation(description: "Cancel scratching")
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            guard let sut = self.sut else { return }
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertFalse(sut.isScratchEnabled)
            XCTAssertFalse(sut.isActivationEnabled)
            XCTAssertFalse(sut.isDeactivationEnabled)
            sut.cancelGenerateCode.accept()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard let sut = self.sut else { return }
            XCTAssertEqual(sut.stateTitle, "Unscratched")
            XCTAssertTrue(sut.isScratchEnabled)
            XCTAssertFalse(sut.isActivationEnabled)
            XCTAssertFalse(sut.isDeactivationEnabled)
            expectation.fulfill()
        }
                                      
        wait(for: [expectation], timeout: 5)
    }
    
    func testScratching() throws {
        let expectation = expectation(description: "Scratch code")
        sut.subscribeGenerateCode.accept()
        sut.shouldGenerateCode.accept()
        sut.$stateTitle
            .first { $0 == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertFalse(sut.isScratchEnabled)
                XCTAssertFalse(sut.isDeactivationEnabled)
                XCTAssertTrue(sut.isActivationEnabled)
                XCTAssertNotNil(sut.generatedCode)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
