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
    func test_init_withPropertiesAllEmpty() {
        let (sut, _) = makeSUT()

        XCTAssertEqual(sut.regionInfoList, [])
        XCTAssertEqual(sut.originalRegionInfoList, [])
        XCTAssertEqual(sut.dataManipulateCommands.count, 0)
    }

    func test_loader_loadedOnlyOnceWhenLoadData() {
        let (sut, loader) = makeSUT()

        sut.loadData{ _ in }

        XCTAssertEqual(loader.messages.count, 1)
    }

    func test_loadData_deliversErrorOnLoaderError() {
        let (sut, loader) = makeSUT()

        let error = NSError(domain: "test", code: 0)
        let exp = expectation(description: "wait for load completion")
        sut.loadData{ result in
            switch result {
            case .success(_):
                XCTFail("Should not success")
            case let .failure(receivedError):
                let receivedError = receivedError as? RegionSelectorManager.Error
                let expectedError = RegionSelectorManager.Error.loadDataFail
                XCTAssertEqual(receivedError, expectedError)
            }
            exp.fulfill()
        }

        loader.complete(with: error)

        waitForExpectations(timeout: 0.1)
    }

    func test_loadData_deliversEmptyOnLoaderGetEmpty() {
        let (sut, loader) = makeSUT()

        let exp = expectation(description: "wait for load completion")
        sut.loadData{ result in
            switch result {
            case .success(let loadedItems):
                XCTAssertEqual(loadedItems, [])
            case .failure(_):
                XCTFail("Should not success")
            }
            exp.fulfill()
        }

        loader.complete(withItems: [])

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(sut.regionInfoList, [])
    }

    func test_loadData_deliverItemsOnLoaderSuccess() {
        let (sut, loader) = makeSUT()

        let exp = expectation(description: "wait for load completion")
        let items = makeItems().list
        sut.loadData{ result in
            switch result {
            case let .success(loadedItems):
                XCTAssertEqual(loadedItems, items)
            case .failure(_):
                XCTFail("Should not success")
            }
            exp.fulfill()
        }

        loader.complete(withItems: items)

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(sut.regionInfoList, items)
        XCTAssertEqual(sut.originalRegionInfoList, items)
    }

    func test_loadData_TwiceGetNewestOnLoaderSuccess() {
        let (sut, loader) = makeSUT()

        let exp = expectation(description: "wait for load completion")
        let twItems = [makeTWItem()]
        let items = makeItems().list
        sut.loadData { _ in }

        loader.complete(withItems: twItems, at: 0)

        sut.loadData{ result in
            switch result {
            case let .success(loadedItems):
                XCTAssertEqual(loadedItems, items)
            case .failure(_):
                XCTFail("Should not success")
            }
            exp.fulfill()
        }

        loader.complete(withItems: items, at: 1)

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(sut.regionInfoList, items)
        XCTAssertEqual(sut.originalRegionInfoList, items)
    }

    func test_sort_byNameSuccess() {
        let items = makeItems()
        let itemsList = items.list
        let itemsTurple = items.tuple
        let (sut, _) = makeLoadedSUT(items: itemsList)

        sut.sort(by: .name)

        XCTAssertEqual(sut.regionInfoList, [itemsTurple.GR, itemsTurple.TW, itemsTurple.US])
    }

    func test_sort_byCountryCodeSuccess() {
        let items = makeItems()
        let itemsList = items.list
        let itemsTurple = items.tuple
        let (sut, _) = makeLoadedSUT(items: itemsList)

        sut.sort(by: .countryCode)

        XCTAssertEqual(sut.regionInfoList, [itemsTurple.GR, itemsTurple.TW, itemsTurple.US])
    }

    func test_sort_byDialCodeSuccess() {
        let items = makeItems()
        let itemsList = items.list
        let itemsTurple = items.tuple
        let (sut, _) = makeLoadedSUT(items: itemsList)

        sut.sort(by: .dialCode)

        XCTAssertEqual(sut.regionInfoList, [itemsTurple.US, itemsTurple.GR, itemsTurple.TW])
    }

    func test_command_executedWhenCallExecute() {
        let items = makeItems()
        let itemsList = items.list
        let (sut, _) = makeLoadedSUT(items: itemsList)

        let dataManipulateCommand = DataManipulateCommandSpy()
        sut.execute(command: dataManipulateCommand)

        XCTAssertEqual(dataManipulateCommand.executedTimes, 1)
    }

    func test_command_executedAgainAfterSorted() {
        let items = makeItems()
        let itemsList = items.list
        let (sut, _) = makeLoadedSUT(items: itemsList)
        let dataManipulateCommand = DataManipulateCommandSpy()
        sut.execute(command: dataManipulateCommand)

        sut.sort(by: .dialCode)

        XCTAssertEqual(dataManipulateCommand.executedTimes, 2)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, loader: RegionDataLoaderSpy) {
        let loader = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func makeLoadedSUT(items: [RegionInfo], file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, loader: RegionDataLoaderSpy) {
        let loader = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: loader)
        sut.simulateDataLoaded(items: items)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
}

extension RegionSelectorManager {
    func simulateDataLoaded(items: [RegionInfo]) {
        self.regionInfoList = items
        self.originalRegionInfoList = items
    }
}

class RegionDataLoaderSpy: RegionDataLoader {
    var isLoaded: Bool = false
    var error: Error?
    typealias Message = ((LoadDataResult) -> Void)
    var messages: [Message] = []

    func load(completion: @escaping (LoadDataResult) -> Void) {
        messages.append(completion)
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index](.failure(error))
    }

    func complete(withItems items:[RegionInfo], at index: Int = 0) {
        messages[index](.success(items))
    }
}

class DataManipulateCommandSpy: DataManipulateCommand {
    private(set) var executedTimes = 0
    var params: [CountryCode] = []

    func execute(diallingCodeList: inout [RegionInfo]) {
        executedTimes += 1
    }
}

