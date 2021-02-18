//
//  RegionDataLoader.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/17.
//

import Foundation

protocol RegionDataLoader {
    func load(completion: @escaping (Result) -> Void)
}
