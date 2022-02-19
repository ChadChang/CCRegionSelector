//
//  DefaulRegionPickViewSnapshotTests.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/10/19.
//

import XCTest
@testable import CCRegionSelector

class DefaulRegionPickViewSnapshotTests: XCTestCase {

    func test_show_TWRegionInfo() {
        let sut = DefaulRegionPickView(regionInfo: makeTWItem())
        let snapshot = sut.snapshot(for: .iPhone13(style: .light))
        assert(snapshot: snapshot, named: "defaulRegionPickView_tw_regionInfo_load")
    }
}

