//
//  Wallet+Sign.swift
//  SChainWallet
//
//  Created by lt on 2023/3/29.
//

import CryptoSwift
import Foundation
import web3swift

public extension Wallet {
    func personalSign(message: String, password: String) -> String? {
        let messageData = message.sc_dropHex.sc_hex2data
        guard let cryptoData = cryptoData else { return nil }
        var privateKey: String?
        do {
            let aes = try AES(key: password.sc_password, iv: self.iv.sc_iv)
            let result = try aes.decrypt(cryptoData.sc_dropHex.sc_hex2data.bytes)
            let rawData = String(decoding: result, as: UTF8.self)
            privateKey = rawData
            if self.method == .mnemonic {
                privateKey = Wallet.mnemonicsToPrivateKey(rawMnemonics: rawData)
            }
        } catch {}

        guard let privateKey = privateKey else { return nil }
        let privateKeyData = privateKey.sc_dropHex.sc_hex2data

        if let hashPersonal = Web3.Utils.hashPersonalMessage(messageData) {
            let signature = SECP256K1.signForRecovery(hash: hashPersonal, privateKey: privateKeyData)
            let tx = signature.serializedSignature?.toHexString().sc_addHex
            return tx
        }
        return nil
    }
}
