//
//  Wallet.swift
//  SChainWallet
//
//  Created by lt on 2023/3/28.
//

import CryptoSwift
import Foundation
import HandyJSON

enum WalletType: String, Codable {
    case mnemonic
    case `private`

    var method: String {
        return self.rawValue
    }

//    var message: String {
//        switch self {
//        case .mnemonic:
//            return R.string.localizable.creating()
//        case .mnemonicImport, .privateImport:
//            return R.string.localizable.importing()
//        }
//    }
}

private let walletStorageName = "WalletStorageKey.data"
public struct Wallet: Codable, HandyJSON {
    public init() {}

    /// 创建方式
    var method: WalletType = .mnemonic
    /// 是否为当前钱包---后续如需要实现多钱包即可筛选
    var isCurrent: Bool = true
    /// 导入数据的加密私钥、助记词
    var cryptoData: String?
    /// 地址
    var address: String?
    /// 作为存储私钥或助记词生成的随机data转换的16进制字符串
    var iv: String = "Wallet"
    /// 钱包创建时间
    var createTime: TimeInterval?
}

// import
public extension Wallet {
    /// 获取当前钱包
    static var current: Wallet? {
        if let wallets = Storage.shared.unarchive(appendPath: walletStorageName, Wallet.self) {
            return wallets.filter { $0.isCurrent }.first
        }
        return nil
    }

    /// 钱包是否已存在
    static func isAlreadyExist(_ address: String) -> Bool {
        if let datas = Storage.shared.unarchive(appendPath: walletStorageName, Wallet.self), datas.count > 0 {
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
        if var datas = Storage.shared.unarchive(appendPath: walletStorageName, Wallet.self), datas.count > 0 {
            for var walletModel in datas {
                if walletModel.isCurrent == true {
                    walletModel.isCurrent = false
                    break
                }
            }
            datas.append(self)
            return Storage.shared.archive(array: datas, appendPath: walletStorageName)
        } else { // 意味着还没有钱包
            return Storage.shared.archive(array: [self], appendPath: walletStorageName)
        }
    }

    /// 切换钱包
    func switchover() -> Bool {
        if let datas = Storage.shared.unarchive(appendPath: walletStorageName, Wallet.self) {
            for var walletModel in datas {
                if walletModel.isCurrent == true {
                    walletModel.isCurrent = false
                    continue
                }
                if walletModel.address == self.address { // 通过id能判断是否为同一个
                    walletModel.isCurrent = true
                }
            }
            return Storage.shared.archive(array: datas, appendPath: walletStorageName)
        }
        return false
    }

    /// 删除钱包
    func remove() -> Bool {
        if var datas = Storage.shared.unarchive(appendPath: walletStorageName, Wallet.self) {
            for (index, walletModel) in datas.enumerated() {
                if walletModel.address == self.address {
                    datas.remove(at: index)
                    if walletModel.isCurrent, datas.count > 0 { // 如果是当前钱包，则需要多处理一步,将剩下的钱包中的第一个设置为当前钱包
                        var current = datas.first!
                        current.isCurrent = true
                    }
                    return Storage.shared.archive(array: datas, appendPath: walletStorageName)
                }
            }
        }
        return false
    }

    func modify() -> Bool {
        if var datas = Storage.shared.unarchive(appendPath: walletStorageName, Wallet.self) {
            for (index, walletModel) in datas.enumerated() {
                if walletModel.address == self.address {
                    datas[index] = self
                    return Storage.shared.archive(array: datas, appendPath: walletStorageName)
                }
            }
        }
        return false
    }
}

// export
public extension Wallet {
    // 校验密码
    func isValidPassword(password: String) throws -> Bool {
        if let data = cryptoData {
            let aes = try AES(key: password.sc_password, iv: self.iv.sc_iv)
            let result = try aes.decrypt(Data(hex: data).bytes)
            if result.count > 0 {
                return true
            }
        }
        return false
    }

    func exportWallet(password: String) throws -> String? {
        guard try self.isValidPassword(password: password) else {
            throw NSError(domain: "Password Incorrect!", code: -1)
        }
        if let data = cryptoData {
            let aes = try AES(key: password.sc_password, iv: self.iv.sc_iv)
            let result = try aes.decrypt(Data(hex: data.sc_dropHex).bytes)
            if result.count > 0 {
                return String(decoding: result, as: UTF8.self)
            }
        }
        return nil
    }
}
