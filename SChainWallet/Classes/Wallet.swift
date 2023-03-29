//
//  Wallet.swift
//  SChainWallet
//
//  Created by lt on 2023/3/28.
//

import CryptoSwift
import Foundation
import HandyJSON
import web3swift

enum WalletType: String, Codable {
    case mnemonic
    case `private`

    var method: String {
        return self.rawValue
    }
}

public struct Wallet: Codable, HandyJSON {
    static let walletStorageName = "WalletStorageKey.data"
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

extension Wallet {
    /// 根据助记词生成钱包
    /// - Parameters:
    ///   - mnemonics: 助记词
    ///   - password: 加密密码
    /// - Returns: 钱包
    static func mnemonicsToWallet(mnemonics: String, password: String) -> Wallet? {
        do {
            let aes = try AES(key: password.sc_password, iv: "Wallet".sc_iv)
            let cryptResult = try aes.encrypt(Array(mnemonics.utf8))

            if let seed = BIP39.seedFromMmemonics(mnemonics), let node = HDNode(seed: seed), let privateData = node.privateKey, let publicData = Web3Utils.privateToPublic(privateData), let address = Web3Utils.publicToAddress(publicData) {
                let ret = Data(bytes: cryptResult).toHexString()
                let dic: JSONObject = [
                    "cryptoData": ret,
                    "address": address.address.lowercased(),
                    "createTime": Date().timeIntervalSince1970
                ]
                if var wallet = JSONDeserializer<Wallet>.deserializeFrom(dict: dic) {
                    wallet.isCurrent = true
                    wallet.method = .mnemonic
                    return wallet
                }
                return nil
            }
        }
        catch {}
        return nil
    }

    /// 根据私钥生成钱包
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - password: 加密密码
    /// - Returns: 钱包
    static func privateKeyToWallet(privateKey: String, password: String) -> Wallet? {
        do {
            let aes = try AES(key: password.sc_password, iv: "Wallet".sc_iv)
            let cryptResult = try aes.encrypt(Array(privateKey.utf8))

            let privateData = privateKey.sc_dropHex.sc_hex2data

            guard let publicData = Web3Utils.privateToPublic(privateData) else {
                return nil
            }

            if let address = Web3Utils.publicToAddress(publicData) {
                let ret = Data(bytes: cryptResult).toHexString()
                let dic: JSONObject = [
                    "cryptoData": ret,
                    "address": address.address.lowercased(),
                    "createTime": Date().timeIntervalSince1970
                ]
                if var wallet = JSONDeserializer<Wallet>.deserializeFrom(dict: dic) {
                    wallet.isCurrent = true
                    wallet.method = .private
                    return wallet
                }
                return nil
            }
        }
        catch {}
        return nil
    }

    /// 助记词转私钥
    /// - Parameter rawMnemonics: 助记词(未加密)
    /// - Returns: 若是合理的助记词则返回私钥，否则 nil
    static func mnemonicsToPrivateKey(rawMnemonics: String) -> String? {
        guard let seed = BIP39.seedFromMmemonics(rawMnemonics) else {
            return nil
        }
        guard let node = HDNode(seed: seed) else {
            return nil
        }

        guard let privateData = node.privateKey else {
            return nil
        }
        return privateData.toHexString()
    }
}
