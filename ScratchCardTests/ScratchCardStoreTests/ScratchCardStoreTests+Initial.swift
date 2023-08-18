//
//  ScratchCardStoreTests+Initial.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 18/08/2023.
//

import XCTest
@testable import ScratchCard
import Combine

class ScratchCardStoreTestsInitial: XCTestCase {
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
    
    func testInitialState() throws {
        XCTAssertEqual(sut.stateTitle, "Unscratched")
        XCTAssertTrue(sut.isScratchEnabled)
        XCTAssertFalse(sut.isActivationEnabled)
        XCTAssertFalse(sut.isDeactivationEnabled)
        XCTAssertNil(sut.generatedCode)
    }
}
