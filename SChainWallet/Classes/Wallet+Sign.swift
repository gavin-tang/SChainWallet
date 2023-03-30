//
//  Wallet+Sign.swift
//  SChainWallet
//
//  Created by lt on 2023/3/29.
//

import BigInt
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

    func signMsg(message: String, passwod: String) -> String? {
        return nil
    }

    func signTransaction(recipient: String, value: String, nonce: String, gasLimit: String, gasPrice: String, payload: String, password: String) -> WalletResponse<String?> {
        let _nonce = BigUInt(stringLiteral: nonce)
        var ops = TransactionOptions.defaultOptions
        ops.nonce = .manual(_nonce)
        ops.chainID = WalletService.share.bigChainID
        ops.to = EthereumAddress(recipient)
        ops.from = EthereumAddress(self.address)
        ops.gasPrice = .manual(BigUInt(stringLiteral: gasPrice))
        ops.gasLimit = .automatic
        ops.callOnBlock = .latest

        var transaction = EthereumTransaction(type: .legacy, to: EthereumAddress(recipient)!, nonce: _nonce, chainID: WalletService.share.bigChainID, value: BigUInt(stringLiteral: value), data: payload.sc_hex2data, v: BigUInt(0), r: BigUInt(0), s: BigUInt(0), parameters: EthereumParameters(from: ops))
        guard let privateKeyData = exportPrivateWallet(password: password)?.sc_hex2data else {
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: "error wallet"))
        }
        try? transaction.sign(privateKey: privateKeyData)
//        transaction.encode()?.toHexString().sc_addHex.lowercased()
        guard let tx = transaction.encode() else {
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: "Transaction generation failed"))
        }
        let w3 = WalletService.share.w3!
        var txhash: String?
        var err: CyError?
        do {
            txhash = try w3.eth.sendRawTransaction(tx).hash
        } catch {
            err = error as? CyError
        }
        return WalletResponse<String?>(data: txhash, error: err)
    }

    func call(payload: String) -> WalletResponse<String?> {
        guard let json = payload.sc_toJson, let to = json["to"] as? String, let data = json["data"] as? String else {
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: "params not emtpy"))
        }
        return WalletService.share.call(from: self.address, to: to, data: data)
    }
}
