//
//  Wallet+Import.swift
//  SChainWallet
//
//  Created by lt on 2023/3/29.
//

import CryptoSwift
import Foundation
// import
public extension Wallet {
    /// 获取当前钱包
    static var current: Wallet? {
        if let wallets = Storage.shared.unarchive(appendPath: Wallet.walletStorageName, Wallet.self) {
            return wallets.filter { $0.isCurrent }.first
        }
        return nil
    }

    /// 钱包是否已存在
    static func isAlreadyExist(_ address: String) -> Bool {
        if let datas = Storage.shared.unarchive(appendPath: Wallet.walletStorageName, Wallet.self), datas.count > 0 {
            for walletModel in datas {
                if walletModel.address == address {
                    return true
                }
            }
        }
        return false
    }

    /// 添加钱包,新增的钱包永远都是当前钱包
    func save() -> Bool {
        if var datas = Storage.shared.unarchive(appendPath: Wallet.walletStorageName, Wallet.self), datas.count > 0 {
            for var walletModel in datas {
                if walletModel.isCurrent == true {
                    walletModel.isCurrent = false
                    break
                }
            }
            datas.append(self)
            return Storage.shared.archive(array: datas, appendPath: Wallet.walletStorageName)
        } else { // 意味着还没有钱包
            return Storage.shared.archive(array: [self], appendPath: Wallet.walletStorageName)
        }
    }

    /// 切换钱包
    func switchover() -> Bool {
        if let datas = Storage.shared.unarchive(appendPath: Wallet.walletStorageName, Wallet.self) {
            for var walletModel in datas {
                if walletModel.isCurrent == true {
                    walletModel.isCurrent = false
                    continue
                }
                if walletModel.address == address { // 通过id能判断是否为同一个
                    walletModel.isCurrent = true
                }
            }
            return Storage.shared.archive(array: datas, appendPath: Wallet.walletStorageName)
        }
        return false
    }

    /// 删除钱包
    func remove() -> Bool {
        if var datas = Storage.shared.unarchive(appendPath: Wallet.walletStorageName, Wallet.self) {
            for (index, walletModel) in datas.enumerated() {
                if walletModel.address == address {
                    datas.remove(at: index)
                    if walletModel.isCurrent, datas.count > 0 { // 如果是当前钱包，则需要多处理一步,将剩下的钱包中的第一个设置为当前钱包
                        var current = datas.first!
                        current.isCurrent = true
                    }
                    return Storage.shared.archive(array: datas, appendPath: Wallet.walletStorageName)
                }
            }
        }
        return false
    }

    func modify() -> Bool {
        if var datas = Storage.shared.unarchive(appendPath: Wallet.walletStorageName, Wallet.self) {
            for (index, walletModel) in datas.enumerated() {
                if walletModel.address == address {
                    datas[index] = self
                    return Storage.shared.archive(array: datas, appendPath: Wallet.walletStorageName)
                }
            }
        }
        return false
    }
}
