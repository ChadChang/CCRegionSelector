//
//  RegionSelectorView.swift
//  RegionSelectorView
//
//  Created by Chad Chang on 2020/09/15.
//

import Foundation

public protocol RegionSelectorViewDelegate: AnyObject {
    func layoutPickView(_ pickerView: UIPickerView)
    func showPickInView() -> UIView
    func phoneCodeDidChange(_ pickerView: UIPickerView, phoneCode: String)
    func customPickerView(_ info: RegionInfo) -> UIView?
}

public class RegionSelectorView: UIView {
    public typealias CountryCode = String
    public weak var delegate: RegionSelectorViewDelegate?

    private var regionSelectorManager: RegionSelectorManager?

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isTranslucent = false

        let cancelItem =  UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(hidePicker))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))

        let barItems = [cancelItem, flexSpace, doneItem]
        toolbar.setItems(barItems, animated: true)
        return toolbar
    }()

    private lazy var dialCodeField: UITextField = {
        let codeField = UITextField()
        codeField.translatesAutoresizingMaskIntoConstraints = false
        codeField.textAlignment = .center
        codeField.font = UIFont.boldSystemFont(ofSize: 18)
        codeField.tintColor = .clear
        return codeField
    }()

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            pickerView.backgroundColor = .systemBackground
        } else {
            pickerView.backgroundColor = .white
        }
        return pickerView
    }()

    private var regionInfoList: [RegionInfo] {
        regionSelectorManager?.regionInfoList ?? []
    }

    // MARK: - View LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        regionSelectorManager = RegionSelectorManager()

        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.dialCodeField)

        dialCodeField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dialCodeField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        dialCodeField.inputView = pickerView
        dialCodeField.inputAccessoryView = toolbar
        dialCodeField.delegate = self

        regionSelectorManager?.loadData(completion: { [weak self] result in
            switch result {
            case .success(_):
                self?.updateSelectView(row: 0)
            case let .failure(error):
                fatalError("Load data fail: \(error)")
            }
        })

    }

    // MARK: - Public Methods
    public func setPinRegions(_ regionList: [CountryCode]) {
        regionSelectorManager?.execute(command: PinCommand(params: regionList))
        self.pickerView.reloadAllComponents()
    }

    public func setDefaultRegion(_ code: CountryCode) {
        let indexToSelect = regionInfoList.firstIndex(where: { $0.countryCode == code})
        if let indexToSelect = indexToSelect {
            pickerView.selectRow(indexToSelect, inComponent: 0, animated: true)
            updateData()
        }
    }

    public func setRestrictRegions(_ restrictList:[CountryCode]) {
        regionSelectorManager?.execute(command: RestrictCommand(params: restrictList))
        self.pickerView.reloadAllComponents()
    }

    // MARK: - Private Methods
    private func updateSelectView(row selectRow: Int) {
        let diallingCode = regionInfoList[selectRow]
        self.dialCodeField.text =  diallingCode.dialCode
    }

    private func updateData() {
        let selectRow = pickerView.selectedRow(inComponent: 0)
        let regionInfo = regionInfoList[selectRow]

        delegate?.phoneCodeDidChange(pickerView, phoneCode: regionInfo.dialCode)

        updateSelectView(row: selectRow)
    }

    // MARK: Actions
    @objc func hidePicker() {
        toolbar.removeFromSuperview()
        pickerView.removeFromSuperview()
    }

    @objc func doneAction() {
        updateData()
        dialCodeField.resignFirstResponder()
    }
}

// MARK: - UIPickerViewDelegate
extension RegionSelectorView: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let regionInfo = regionInfoList[row]

        if let customPickerView = self.delegate?.customPickerView(regionInfo) {
            return customPickerView
        }
        return DefaulRegionPickView(regionInfo: regionInfo)
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        44.0
    }
}

// MARK: - UIPickerViewDataSource
extension RegionSelectorView: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        regionInfoList.count
    }
}

// MARK: - UITextFieldDelegate
extension RegionSelectorView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }
}
