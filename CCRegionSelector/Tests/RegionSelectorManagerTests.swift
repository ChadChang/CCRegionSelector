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
    func load()
}

class RegionSelectorManager {
    private let dataLoader: RegionDataLoader

    init(dataLoader: RegionDataLoader) {
        self.dataLoader = dataLoader
    }
    func loadData() {
        self.dataLoader.load()
    }
}

class RegionSelectorManagerTests: XCTestCase {
    func test_init_doestNotNil() {
        let (sut, _) = makeSUT()
        XCTAssertNotNil(sut)
    }

    func test_dataloader_loadedWhenLoadData() {
        let (sut, client) = makeSUT()
        sut.loadData()
        XCTAssertTrue(client.isLoaded)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, client: RegionDataLoaderSpy) {
        let client = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}

class RegionDataLoaderSpy: RegionDataLoader {
    var isLoaded: Bool = false
    func load() {
        isLoaded = true
    }
}



