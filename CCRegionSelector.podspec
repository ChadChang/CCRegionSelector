#
# Be sure to run `pod lib lint CCRegionSelector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CCRegionSelector'
  s.version          = '1.1.0'
  s.summary          = 'A custom view to select a region'
  s.swift_version    = '5.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A custom view to select a region and written in Swift.'  
  s.homepage         = 'https://github.com/ChadChang/CCRegionSelector'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ChadChang' => 'chadchang.tw@gmail.com' }
  s.source           = { :git => 'https://github.com/ChadChang/CCRegionSelector.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/CCRegionSelector/Classes/**/*'
  s.resources = 'Sources/CCRegionSelector/Assets/*.{json}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/CCRegionSelectorTests/**/*'
  end
end
