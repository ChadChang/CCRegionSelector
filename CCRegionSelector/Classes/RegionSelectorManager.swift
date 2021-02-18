//
//  RegionSelectorManager.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/17.
//

import Foundation

typealias Result = Swift.Result<[RegionInfo], Error>

class RegionSelectorManager {
    enum SortType {
        case name
        case dialCode
        case countryCode
    }

    // TODO: should not public getter only for test purpose
    var originalRegionInfoList: [RegionInfo] = []
    var regionInfoList: [RegionInfo] = []
    private(set) var dataManipulateCommands: [DataManipulateCommand] = []
    private let dataLoader: RegionDataLoader

    init(dataLoader: RegionDataLoader = DefaultRegionDataLoader()) {
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
