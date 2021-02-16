//
//  Array+Helper.swift
//  CCRegionSelector
//
//  Created by Chad Chang on 2021/2/16.
//

import Foundation

extension Array where Element == RegionInfo {
    mutating func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { objA, objB in
            return objA[keyPath: keyPath] < objB[keyPath: keyPath]
        }
    }

    func rearrange(fromIndex: Int, toIndex: Int) -> [Element] {
        var array = self
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        return array
    }

    func findByCountryCode(_ code: String) -> Element? {
        return self.first { $0.countyCode == code }
    }
}
