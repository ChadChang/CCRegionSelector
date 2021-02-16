//
//  RegionSelectorManagerTests.swift
//  CCRegionSelector_Tests
//
//  Created by Chad Chang on 2020/09/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import CCRegionSelector

protocol DataManipulateCommand {
    typealias CountryCode = String
    var params: [CountryCode] { get }
    func execute(diallingCodeList: inout [RegionInfo])
}

typealias Result = Swift.Result<[RegionInfo], Error>
protocol RegionDataLoader {
    func load(completion: @escaping (Result) -> Void)
}

class RegionSelectorManager {
    enum SortType {
        case name
        case dialCode
        case countryCode
    }

    // TODO: should not public getter only for test purpose
    private(set) var originalRegionInfoList: [RegionInfo] = []
    private(set) var regionInfoList: [RegionInfo] = []
    private(set) var dataManipulateCommands: [DataManipulateCommand] = []
    private let dataLoader: RegionDataLoader

    init(dataLoader: RegionDataLoader) {
        self.dataLoader = dataLoader
    }

    func loadData(completion: @escaping (Result) -> Void) {
        self.dataLoader.load(completion: { [weak self] result in
            switch result {
            case let .success(items):
                self?.originalRegionInfoList = items
                self?.regionInfoList = items
                completion(.success(items))
            case .failure(_):
                completion(result)
            }
        })
    }

    func sort(by type: SortType) {
        switch type {
        case .name:
            self.regionInfoList = self.originalRegionInfoList.sorted(by: \.name)
        case .dialCode:
            self.regionInfoList = self.originalRegionInfoList.sorted(by: \.dialCode)
        case .countryCode:
            self.regionInfoList = self.originalRegionInfoList.sorted(by: \.countryCode)
        }

        dataManipulateCommands.forEach {
            $0.execute(diallingCodeList: &self.regionInfoList)
        }
    }

    func execute(command: DataManipulateCommand) {
        guard self.regionInfoList.count > 0 else { return }
        dataManipulateCommands.append(command)
        command.execute(diallingCodeList: &self.regionInfoList)
    }
}

class RegionSelectorManagerTests: XCTestCase {
    func test_init_withPropertiesAllEmpty() {
        let (sut, _) = makeSUT()

        XCTAssertTrue(sut.regionInfoList.isEmpty)
        XCTAssertTrue(sut.dataManipulateCommands.isEmpty)
    }

    func test_loader_loadedOnlyOnceWhenLoadData() {
        let (sut, loader) = makeSUT()

        sut.loadData{ _ in }

        XCTAssertEqual(loader.messages.count, 1)
    }

    func test_loadData_deliversErrorOnLoaderError() {
        let (sut, loader) = makeSUT()

        let error = NSError(domain: "test", code: 0)
        var captureError: Error?
        let exp = expectation(description: "wait for load completion")
        sut.loadData{ result in
            switch result {
            case .success(_):
                XCTFail("Should not success")
            case let .failure(error):
                captureError = error
                XCTAssertEqual(error as NSError?, captureError as NSError?)
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

    private func makeItem(name: String, countryCode: String, dialCode: String) -> RegionInfo {
        let item = RegionInfo(name: name, countryCode: countryCode, dialCode: dialCode)
        return item
    }

    typealias RegionInfoTuple = (TW: RegionInfo, US: RegionInfo, GR: RegionInfo)

    private func makeItems() -> (list:[RegionInfo], tuple: RegionInfoTuple) {
        let twItem = makeTWItem()
        let usItem = makeUSItem()
        let grItem = makeGreeceItem()
        return (list: [twItem, usItem, grItem] , tuple:(TW: makeTWItem(), US: makeUSItem(), GR: makeGreeceItem()))
    }

    private func makeTWItem() -> RegionInfo {
        let item = RegionInfo(name: "Taiwan", countryCode: "TW", dialCode: "+886")
        return item
    }

    private func makeUSItem() -> RegionInfo {
        let item = RegionInfo(name: "United States", countryCode: "US", dialCode: "+1")
        return item
    }

    private func makeGreeceItem() -> RegionInfo {
        let item = RegionInfo(name: "Greece", countryCode: "GR", dialCode: "+30")
        return item
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
    typealias Message = ((Result) -> Void)
    var messages: [Message] = []

    func load(completion: @escaping (Result) -> Void) {
        messages.append(completion)
    }

    func complete(with error: Error) {
        messages[0](Result.failure(error))
    }

    func complete(withItems items:[RegionInfo]) {
        messages[0](Result.success(items))
    }
}

class DataManipulateCommandSpy: DataManipulateCommand {
    private(set) var executedTimes = 0
    var params: [CountryCode] = []

    func execute(diallingCodeList: inout [RegionInfo]) {
        executedTimes += 1
    }
}

