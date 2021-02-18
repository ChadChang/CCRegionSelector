//
//  ViewController.swift
//  CCRegionSelector
//
//  Created by ChadChang on 2020/09/15.
//  Copyright (c) 2020 ChadChang. All rights reserved.
//

import UIKit
import CCRegionSelector

class ViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var selectView: RegionSelectorView!

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectView.delegate = self
        selectView.setPinRegion(code: ["TW", "HK"])
        selectView.setDefaultRegion("HK")
        selectView.setRestrictRegions(["TW","US","CA"])
    }
}

// MARK: - RegionSelectorViewDelegate
extension ViewController: RegionSelectorViewDelegate {
    func layoutPickView(_ pickerView: UIPickerView) {
        pickerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        pickerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    func showPickInView() -> UIView { self.view }

    func phoneCodeDidChange(_ pickerView: UIPickerView, phoneCode: String) {
        print(phoneCode)
    }

    func customPickerView(_ info: RegionInfo) -> UIView? {
        // return nil if use default picker view
        nil
        // use custom picker view
        // RandomColorCountryPickerView(regionInfo: info)
    }
}
