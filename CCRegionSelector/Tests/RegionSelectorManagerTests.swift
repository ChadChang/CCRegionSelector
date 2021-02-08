//
//  RegionSelectorManagerTests.swift
//  CCRegionSelector_Tests
//
//  Created by Chad Chang on 2020/09/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import CCRegionSelector

class RegionSelectorManagerTests: XCTestCase {
    func test_init_doestNotNil() {
        let sut = RegionSelectorManager()
        XCTAssertNotNil(sut)
    }
}
