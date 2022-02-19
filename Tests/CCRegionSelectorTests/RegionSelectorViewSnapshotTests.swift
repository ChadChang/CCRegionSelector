//
//  RegionSelectorViewSnapshotTests.swift
//  CCRegionSelector-Unit-Tests
//
//  Created by Chad Chang on 2021/10/19.
//

import XCTest
@testable import CCRegionSelector

class RegionSelectorViewSnapshotTests: XCTestCase {

    func test_InitLoad() {
        let sut = RegionSelectorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let snapshot = sut.snapshot(for: .init(size: sut.frame.size))
        assert(snapshot: snapshot, named: "init_load")
    }
}
