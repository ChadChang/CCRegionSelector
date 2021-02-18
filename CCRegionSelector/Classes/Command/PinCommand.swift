//
//  PinCommand.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2020/09/15.
//

import Foundation

class PinCommand: DataManipulateCommand {
    var params: [CountryCode]

    init(params: [CountryCode]) {
        self.params = params
    }

    func execute(diallingCodeList: inout [RegionInfo]) {
        // TODO: better algro
        for param in self.params.reversed() {
            guard let element = diallingCodeList.findByCountryCode(param),
                let elementIndex = diallingCodeList.firstIndex(of: element) else { return }

            let list = diallingCodeList.rearrange(fromIndex: elementIndex, toIndex: 0)
            diallingCodeList = list
        }
    }
}
