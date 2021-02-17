//
//  DefaultRegionDataLoaderTests.swift
//  CCRegionSelector-Unit-Tests
//
//  Created by Chad Chang on 2021/2/17.
//

import XCTest
@testable import CCRegionSelector
class DefaultRegionDataLoaderTests: XCTestCase {
    func test_init_shouldNotNil() {
        let sut = makeSUT()

        XCTAssertNotNil(sut)
    }

    func test_load_successWithRegionInfos() {
        let sut = makeSUT()

        let exp = expectation(description: "wait for load completion")

        sut.load { result in
            switch result {
            case let .success(regionInfoList):
                XCTAssertGreaterThan(regionInfoList.count, 0)
            case .failure(_):
                XCTFail("Should not failure")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> DefaultRegionDataLoader {
        let sut = DefaultRegionDataLoader()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
