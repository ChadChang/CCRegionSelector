//
//  DataManipulateCommand.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/17.
//

import Foundation

protocol DataManipulateCommand {
    typealias CountryCode = String
    var params: [CountryCode] { get }
    func execute(diallingCodeList: inout [RegionInfo])
}
