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
        sut.send.accept(.subscribeGenerateCode)
        sut.send.accept(.startGenerateCode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            guard let sut = self.sut else { return }
            XCTAssertEqual(sut.state.title, "Unscratched")
            XCTAssertFalse(sut.state.enableScratch)
            XCTAssertFalse(sut.state.enableActivation)
            XCTAssertFalse(sut.state.enableDeactivation)
            sut.send.accept(.cancelGenerateCode)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard let sut = self.sut else { return }
            XCTAssertEqual(sut.state.title, "Unscratched")
            XCTAssertTrue(sut.state.enableScratch)
            XCTAssertFalse(sut.state.enableActivation)
            XCTAssertFalse(sut.state.enableDeactivation)
            expectation.fulfill()
        }
                                      
        wait(for: [expectation], timeout: 5)
    }
    
    func testScratching() throws {
        let expectation = expectation(description: "Scratch code")
        sut.send.accept(.subscribeGenerateCode)
        sut.send.accept(.startGenerateCode)
        sut.$state
            .first { $0.title == "Scratched" }
            .delay(for: 0.2, scheduler: RunLoop.current)
            .sink { _ in
                guard let sut = self.sut else { return }
                XCTAssertFalse(sut.state.enableScratch)
                XCTAssertFalse(sut.state.enableDeactivation)
                XCTAssertTrue(sut.state.enableActivation)
                XCTAssertNotNil(sut.state.generatedCode)
                expectation.fulfill()
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3)
    }
}
