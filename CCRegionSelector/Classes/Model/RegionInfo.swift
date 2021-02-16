//
//  RegionInfo.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/9.
//

import Foundation

struct RegionInfo: Codable, Equatable {
    let name: String
    let countyCode: String
    let dialCode: String

    enum CodingKeys: String, CodingKey {
        case countyCode = "code"
        case name
        case dialCode
    }
}