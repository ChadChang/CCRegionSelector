//
//  RegionSelectorManagerTests.swift
//  CCRegionSelector_Tests
//
//  Created by Chad Chang on 2020/09/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import CCRegionSelector

struct RegionInfo: Codable, Equatable {
    let name: String
    let countyCode: String
    let dialCode: String

    enum CodingKeys: String, CodingKey {
        case countyCode = "code"
        case name
        case dialCode
    }
}


typealias Result = Swift.Result<[RegionInfo], Error>
protocol RegionDataLoader {
    func load(completion: @escaping (Result) -> Void)
}

class RegionSelectorManager {
    private let dataLoader: RegionDataLoader
    private(set) var regionInfoList: [RegionInfo] = []

    init(dataLoader: RegionDataLoader) {
        self.dataLoader = dataLoader
    }

    func loadData(completion: @escaping (Result) -> Void) {
        self.dataLoader.load(completion: { [weak self] result in
            switch result {
            case let .success(items):
                self?.regionInfoList = items
                completion(.success(items))
            case .failure(_):
                completion(result)
            }
        })
    }
}

class RegionSelectorManagerTests: XCTestCase {
    func test_init_doestNotNil() {
        let (sut, _) = makeSUT()
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.regionInfoList.isEmpty)
    }

    func test_dataloader_loadedWhenLoadData() {
        let (sut, loader) = makeSUT()
        sut.loadData{ _ in }
        XCTAssertNotNil(loader.message)
    }

    func test_loadData_deliversErrorOnLoaderError() {
        let (sut, loader) = makeSUT()
        let error = NSError(domain: "test", code: 0)
        var captureError: Error?
        sut.loadData{ result in
            switch result {
            case .success(_):
                XCTAssertThrowsError("Should not success")
            case let .failure(error):
                captureError = error
            }
        }
        loader.complete(with: error)
        XCTAssertEqual(error, captureError as NSError?)
    }

    func test_loadData_deliversEmptyOnLoaderGetEmpty() {
        let (sut, loader) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        sut.loadData{ [weak sut] result in
            switch result {
            case .success(_):
                XCTAssertEqual(sut?.regionInfoList, [])
            case .failure(_):
                XCTAssertThrowsError("Should not success")
            }
            exp.fulfill()
        }
        loader.complete(withItems: [])
        waitForExpectations(timeout: 0.1)
    }

    func test_loadData_deliverItemsOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        let item1 = makeItem(name: "name", countryCode: "anyCountryCode", dialCode: "code")
        let item2 = makeItem(name: "another_name", countryCode: "another_anyCountryCode", dialCode: "another_code")
        sut.loadData{ [weak sut] result in
            switch result {
            case .success(_):
                XCTAssertEqual(sut?.regionInfoList, [item1, item2])
            case .failure(_):
                XCTAssertThrowsError("Should not success")
            }
            exp.fulfill()
        }
        loader.complete(withItems: [item1,item2])
        waitForExpectations(timeout: 0.1)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, loader: RegionDataLoaderSpy) {
        let loader = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func makeItem(name: String, countryCode: String, dialCode: String) -> RegionInfo {
        let item = RegionInfo(name: name, countyCode: countryCode, dialCode: dialCode)
        return item
    }
}

class RegionDataLoaderSpy: RegionDataLoader {
    var isLoaded: Bool = false
    var error: Error?
    typealias Message = ((Result) -> Void)
    var message: Message?

    func load(completion: @escaping (Result) -> Void) {
        message = completion
    }

    func complete(with error: Error) {
        message?(Result.failure(error))
    }

    func complete(withItems items:[RegionInfo]) {
        message?(Result.success(items))
    }
}



