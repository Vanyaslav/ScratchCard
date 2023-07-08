//
//  StoreRetainCycleTests.swift
//  ScratchCardTests
//
//  Created by Tomas Baculák on 11/06/2023.
//

import XCTest
@testable import ScratchCard

final class StoreRetainCycleTests: XCTestCase {

    func testStoreDeallocation() {
        var store: AppStateStore? = AppStateStore()
        
        weak var weakStore: AppStateStore?
        
        autoreleasepool {
            weakStore = store
            store = nil
        }

        XCTAssertNil(weakStore, "Store should be deallocated")
    }
}
