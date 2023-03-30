//
//  Wallet+Export.swift
//  SChainWallet
//
//  Created by lt on 2023/3/29.
//

import CryptoSwift
import Foundation

// export
public extension Wallet {
    // 校验密码
    func isValidPassword(password: String) throws -> Bool {
        if let data = cryptoData {
            let aes = try AES(key: password.sc_password, iv: self.iv.sc_iv)
            let result = try aes.decrypt(data.sc_dropHex.sc_hex2data.bytes)
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
            let result = try aes.decrypt(data.sc_dropHex.sc_hex2data.bytes)
            if result.count > 0 {
                return String(decoding: result, as: UTF8.self)
            }
        }
        return nil
    }

    func exportPrivateWallet(password: String) -> String? {
        do {
            let raw = try exportWallet(password: password)
            if self.method == .mnemonic, let raw = raw {
                return Wallet.mnemonicsToPrivateKey(rawMnemonics: raw)
            }
            return raw
        } catch {}
        return nil
    }
}
