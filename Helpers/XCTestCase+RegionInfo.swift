//
//  XCTestCase+RegionInfo.swift
//  CCRegionSelector-Unit-Tests
//
//  Created by Chad Chang on 2021/10/19.
//

import XCTest
@testable import CCRegionSelector

extension XCTestCase {
    typealias RegionInfoTuple = (TW: RegionInfo, US: RegionInfo, GR: RegionInfo)

    func makeItem(name: String, countryCode: String, dialCode: String) -> RegionInfo {
        let item = RegionInfo(name: name, countryCode: countryCode, dialCode: dialCode)
        return item
    }

    func makeItems() -> (list:[RegionInfo], tuple: RegionInfoTuple) {
        let twItem = makeTWItem()
        let usItem = makeUSItem()
        let grItem = makeGreeceItem()
        return (list: [twItem, usItem, grItem] , tuple:(TW: makeTWItem(), US: makeUSItem(), GR: makeGreeceItem()))
    }

    func makeTWItem() -> RegionInfo {
        let item = RegionInfo(name: "Taiwan", countryCode: "TW", dialCode: "+886")
        return item
    }

    func makeUSItem() -> RegionInfo {
        let item = RegionInfo(name: "United States", countryCode: "US", dialCode: "+1")
        return item
    }

    func makeGreeceItem() -> RegionInfo {
        let item = RegionInfo(name: "Greece", countryCode: "GR", dialCode: "+30")
        return item
    }
}
