//
//  RegionInfo.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/9.
//

import Foundation

public struct RegionInfo: Codable, Equatable {
    public let name: String
    public let countryCode: String
    public let dialCode: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "code"
        case name
        case dialCode
    }
}
