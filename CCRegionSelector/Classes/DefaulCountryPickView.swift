//
//  CustomCountryPickView.swift
//  CustomCountryPickView
//
//  Created by Chad on 10/16/15.
//  Copyright © 2015 Chad. All rights reserved.
//
import UIKit

class DefaulCountryPickView: UIView {
    private let regionInfo: RegionInfo
    private let countryNameLabel: UILabel = UILabel()
    private let phoneCodeLabel: UILabel = UILabel()

    // MARK: - View LifeCycle
    required init?(coder: NSCoder) {
        fatalError("should init with regionInfo")
    }

    init(regionInfo: RegionInfo) {
        self.regionInfo = regionInfo
        super.init(frame: CGRect.zero)
        commomInit()
    }

    // MARK: - Private Methods
    private func commomInit() {
        countryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        countryNameLabel.text = regionInfo.name
        addSubview(countryNameLabel)

        countryNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        countryNameLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true

        phoneCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneCodeLabel.text = regionInfo.dialCode
        addSubview(phoneCodeLabel)

        phoneCodeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        phoneCodeLabel.leadingAnchor.constraint(equalTo: countryNameLabel.trailingAnchor, constant: 10).isActive = true
        phoneCodeLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
    }
}
