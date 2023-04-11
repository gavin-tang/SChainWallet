# SChainWallet

[![CI Status](https://img.shields.io/travis/3839147/SChainWallet.svg?style=flat)](https://travis-ci.org/3839147/SChainWallet)
[![Version](https://img.shields.io/cocoapods/v/SChainWallet.svg?style=flat)](https://cocoapods.org/pods/SChainWallet)
[![License](https://img.shields.io/cocoapods/l/SChainWallet.svg?style=flat)](https://cocoapods.org/pods/SChainWallet)
[![Platform](https://img.shields.io/cocoapods/p/SChainWallet.svg?style=flat)](https://cocoapods.org/pods/SChainWallet)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SChainWallet is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SChainWallet'
```

## Author

3839147, abc@qq.com

## License

SChainWallet is available under the MIT license. See the LICENSE file for more info.


## 更新步骤
> 改 podspec文件为最新版本号

```ruby
1. git tag -m "update release" 0.2.0
2. git push --tags
3. pod spec lint SChainWallet.podspec  --allow-warnings --verbose  --skip-tests --skip-import-validation
4. pod repo push SChainWallet SChainWallet.podspec --allow-warnings --verbose  --skip-tests
```
