//
//  RegionDataLoader.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/17.
//

import Foundation

public typealias LoadDataResult = Result<[RegionInfo], Error>

public protocol RegionDataLoader {
    func load(completion: @escaping (LoadDataResult) -> Void)
}
