//
//  RegionSelectorManagerTests.swift
//  CCRegionSelector_Tests
//
//  Created by Chad Chang on 2020/09/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import CCRegionSelector

protocol RegionDataLoader {

}

class RegionSelectorManager {
    private let dataLoader: RegionDataLoader

    init(dataLoader: RegionDataLoader) {
        self.dataLoader = dataLoader
    }
}

class RegionSelectorManagerTests: XCTestCase {
    func test_init_doestNotNil() {
        let (sut, _) = makeSUT()
        XCTAssertNotNil(sut)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, client: RegionDataLoader) {
        let client = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}

class RegionDataLoaderSpy: RegionDataLoader{

}



