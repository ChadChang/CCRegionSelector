# CCRegionSelector

[![CI Status](https://img.shields.io/travis/ChadChang/CCRegionSelector.svg?style=flat)](https://travis-ci.org/ChadChang/CCRegionSelector)
[![Version](https://img.shields.io/cocoapods/v/CCRegionSelector.svg?style=flat)](https://cocoapods.org/pods/CCRegionSelector)
[![License](https://img.shields.io/cocoapods/l/CCRegionSelector.svg?style=flat)](https://cocoapods.org/pods/CCRegionSelector)
[![Platform](https://img.shields.io/cocoapods/p/CCRegionSelector.svg?style=flat)](https://cocoapods.org/pods/CCRegionSelector)

| Default | Custom Picker|
|---|---|
| ![DEMO](./Screenshot/demo.png)  |  ![Custom picker](./Screenshot/custom_picker.png) |

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

Add the CCRegionSelectorView to your View, then follow `RegionSelectorViewDelegate` protocol

* `showPickInView()` return a view where UIPickerView placed

``` swift
  func showPickInView()->UIView {
    return self.view
  }

```

* `phoneCodeDidChange()` will receive a phone code where user select a region.

``` swift
  func phoneCodeDidChange(phoneCode: String) {
    print(phoneCode)
  }
```

* `customPickerView(_ info: RegionInfo)` retrun a picker view

``` swift
    func customPickerView(_ info: RegionInfo) -> UIView? {
        // return nil if use default picker view
        nil
        // use custom picker view
        // RandomColorRegionPickerView(regionInfo: info)
    }
```

## Optional

* `setDefaultRegion()` to set an initial region.

``` swift
  selectView.setDefaultRegion("TW")
```
* By passing a string array to `setPinRegions()` to mark frequently used.

``` swift
  selectView.setPinRegions(["TW", "CA"])
```
* By passing a string array to `setRestrictRegions()` to show only those regions desired.

``` swift
  selectView.setRestrictRegions(["TW","US","CA"])
```

## Installation

CCRegionSelector is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CCRegionSelector'
```

## Author

ChadChang, chadchang.tw at gmail.com

## License

CCRegionSelector is available under the MIT license. See the LICENSE file for more info.

## Attributions

* https://gist.github.com/Goles/3196253