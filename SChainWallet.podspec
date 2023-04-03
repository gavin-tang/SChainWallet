#
# Be sure to run `pod lib lint SChainWallet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SChainWallet'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SChainWallet.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here abc@qq.com.
                       DESC

  s.homepage         = 'https://github.com/gavin-tang/SChainWallet'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gavin-tang' => 'abc@qq.com' }
  s.source           = { :git => 'https://github.com/gavin-tang/SChainWallet.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'SChainWallet/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SChainWallet' => ['SChainWallet/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.static_framework = true
  s.dependency 'CoreBitcoin', '0.6.8.1'
  s.dependency 'web3swift', '2.6.4'
  s.dependency 'Alamofire', '5.6.1'
  s.dependency 'HandyJSON'
end
