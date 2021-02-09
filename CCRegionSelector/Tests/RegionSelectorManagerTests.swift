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
            self.regionInfoList = self.originalRegionInfoList.sorted(by: \.countyCode)
        }
    }

    func execute(command: DataManipulateCommand) {
        guard self.regionInfoList.count > 0 else { return }
        dataManipulateCommands.append(command)
        command.execute(diallingCodeList: &self.regionInfoList)
    }
}

extension Array where Element == RegionInfo {
    mutating func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { objA, objB in
            return objA[keyPath: keyPath] < objB[keyPath: keyPath]
        }
    }

    func rearrange(fromIndex: Int, toIndex: Int) -> [Element] {
        var array = self
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        return array
    }

    func findByCountryCode(_ code: String) -> Element? {
        return self.first { $0.countyCode == code }
    }
}

class RegionSelectorManagerTests: XCTestCase {
    func test_init_doestNotNil() {
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
        let items = makeItems()
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
        let (sut, _) = makeSUT()
        let items = makeItems()
        sut.simulateDataLoaded(items: items)
        sut.sort(by: .name)
        XCTAssertEqual(sut.regionInfoList, [items.findByCountryCode("GR"), items.findByCountryCode("TW"), items.findByCountryCode("US")])
    }

    func test_sort_byCountryCodeSuccess() {
        let (sut, _) = makeSUT()
        let items = makeItems()
        sut.simulateDataLoaded(items: items)
        sut.sort(by: .countryCode)
        XCTAssertEqual(sut.regionInfoList, [items.findByCountryCode("GR"), items.findByCountryCode("TW"), items.findByCountryCode("US")])
    }

    func test_sort_byDialCodeSuccess() {
        let (sut, _) = makeSUT()
        let items = makeItems()
        sut.simulateDataLoaded(items: items)
        sut.sort(by: .dialCode)
        XCTAssertEqual(sut.regionInfoList, [items.findByCountryCode("US"), items.findByCountryCode("GR"), items.findByCountryCode("TW")])
    }

    func test_command_executedWhenCallExecute() {
        let (sut, _) = makeSUT()
        let items = makeItems()
        sut.simulateDataLoaded(items: items)
        let dataManipulateCommand = DataManipulateCommandSpy()
        sut.execute(command: dataManipulateCommand)
        XCTAssertTrue(dataManipulateCommand.isExecuted)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegionSelectorManager, loader: RegionDataLoaderSpy) {
        let loader = RegionDataLoaderSpy()
        let sut = RegionSelectorManager(dataLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func makeItems() -> [RegionInfo] {
        let item1 = RegionInfo(name: "Taiwan", countyCode: "TW", dialCode: "+886")
        let item2 = RegionInfo(name: "United States", countyCode: "US", dialCode: "+1")
        let item3 = RegionInfo(name: "Greece", countyCode: "GR", dialCode: "+30")
        return [item1, item2, item3]
    }

    private func makeItem(name: String, countryCode: String, dialCode: String) -> RegionInfo {
        let item = RegionInfo(name: name, countyCode: countryCode, dialCode: dialCode)
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
    private(set) var isExecuted = false
    var params: [CountryCode] = []

    func execute(diallingCodeList: inout [RegionInfo]) {
        isExecuted = true
    }
}

