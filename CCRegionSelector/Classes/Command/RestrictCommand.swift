//
//  RestrictCommand.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/19.
//

import Foundation

class RestrictCommand: DataManipulateCommand {
    var params: [CountryCode]

    init(params: [CountryCode]) {
        self.params = params
    }

    func execute(diallingCodeList: inout [RegionInfo]) {
        diallingCodeList = diallingCodeList.filter { params.contains($0.countryCode)
        }
    }
}
