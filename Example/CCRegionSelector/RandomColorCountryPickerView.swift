//
//  CustomCountryPickerView.swift
//  CCCountrySelector
//
//  Created by Chad on 2020/09/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import CCRegionSelector

class RandomColorCountryPickerView: UIView {
    private let regionInfo: RegionInfo
    private let countryNameLabel = UILabel()

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
        countryNameLabel.font = .boldSystemFont(ofSize: 20)
        countryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        countryNameLabel.text = regionInfo.name
        countryNameLabel.textColor = .random
        addSubview(countryNameLabel)

        countryNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        countryNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
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
