//
//  RegionSelectorManagerTests.swift
//  CCRegionSelector_Tests
//
//  Created by Chad Chang on 2020/09/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import CCRegionSelector

typealias Result = Swift.Result<Void, Error>
protocol RegionDataLoader {
    func load(completion: @escaping (Result) -> Void)
}

class RegionSelectorManager {
    private let dataLoader: RegionDataLoader

    init(dataLoader: RegionDataLoader) {
        self.dataLoader = dataLoader
    }

    @discardableResult
    func loadData(completion: @escaping (Result) -> Void) {
        self.dataLoader.load(completion: { result in
            completion(result)
        })
    }
}

class RegionSelectorManagerTests: XCTestCase {
    func test_init_doestNotNil() {
        let (sut, _) = makeSUT()
        XCTAssertNotNil(sut)
    }

    func test_dataloader_loadedWhenLoadData() {
        let (sut, loader) = makeSUT()
        sut.loadData{ _ in }
        XCTAssertNotNil(loader.message)
    }

    func test_loadData_deliversErrorOnClientError() {
        let (sut, loader) = makeSUT()
        let error = NSError(domain: "test", code: 0)
        var captureError: Error?
        sut.loadData{ result in
            switch result {
            case .success():
                XCTAssertThrowsError("Should not success")
            case let .failure(error):
                captureError = error
            }
        }
        loader.complete(with: error)
        XCTAssertEqual(error, captureError as! NSError)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, loader: RegionDataLoaderSpy) {
        let loader = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
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
}



