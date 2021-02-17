//
//  DefaultJSONRegionData.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2020/09/13.
//

import Foundation
enum DefaultRegionDataLoaderError: Error {
    case loadFail
}
class DefaultRegionDataLoader: RegionDataLoader {
    private enum Constant {
        static let diallingcodeFileName = "diallingcode"
    }

    func load(completion: @escaping (Result) -> Void) {
        if let regionData = loadRegionData(),
           let regionDataList = decodeToDailingCodeList(from: regionData) {
            completion(.success(regionDataList))
            return
        }
        
        completion(.failure(DefaultRegionDataLoaderError.loadFail))
    }

    private func loadRegionData() -> Data? {
        let podBundle = Bundle(for: type(of: self))
        if let path = podBundle.path(forResource: Constant.diallingcodeFileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                // TODO: handle error
                print(error.localizedDescription)
                return nil
            }
        }
        return nil
    }

    private func decodeToDailingCodeList(from data: Data) -> [RegionInfo]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let diallingCodeList = try decoder.decode([RegionInfo].self, from: data)
            return diallingCodeList
        } catch {
            // TODO: handle error
            print(error.localizedDescription)
        }
        return nil
    }
}
