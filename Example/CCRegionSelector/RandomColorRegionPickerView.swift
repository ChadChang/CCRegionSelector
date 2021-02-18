//
//  RandomColorRegionPickerView.swift
//  CCRegionSelector
//
//  Created by Chad on 2020/09/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import CCRegionSelector

class RandomColorRegionPickerView: UIView {
    private let regionInfo: RegionInfo
    private let regionNameLabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError("should init with regionInfo")
    }

    init(regionInfo: RegionInfo) {
        self.regionInfo = regionInfo
        super.init(frame: .zero)
        commomInit()
    }

    // MARK: - Private Methods
    private func commomInit() {
        regionNameLabel.font = .boldSystemFont(ofSize: 20)
        regionNameLabel.translatesAutoresizingMaskIntoConstraints = false
        regionNameLabel.text = regionInfo.name
        regionNameLabel.textColor = .random
        addSubview(regionNameLabel)

        regionNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        regionNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
// MARK: - UIColor Helper
extension UIColor {
    static var random: UIColor { .init(red: .random(in: 0...1),
                                       green: .random(in: 0...1),
                                       blue: .random(in: 0...1),
                                       alpha: 1.0)
    }
}
