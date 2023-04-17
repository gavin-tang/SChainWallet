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
        let messageData = message.sc_dropHex.data(using: .utf8)
        guard let privateKey = exportPrivateWallet(password: password) else { return nil }
        let privateKeyData = privateKey.sc_dropHex.sc_hex2data
        if let messageData = messageData, let hashPersonal = Web3.Utils.hashPersonalMessage(messageData) {
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
        
        // 增加余额不足的判断和转账
        let service = WalletService.share
        guard let balance = service.getNativeTokenBalance(address: address)?.data else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get balance fail"))
        }

        let zzzzz = BigUInt(1000000000000000000)
        if balance! < zzzzz {
            let rst = service.applyTransfer(address: address)
            if rst == false {
                return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get balance fail"))
            }
        }
        
        let _nonce = BigUInt(stringLiteral: nonce)
        var ops = TransactionOptions.defaultOptions
        ops.nonce = .manual(_nonce)
        ops.chainID = WalletService.share.bigChainID
        ops.to = EthereumAddress(recipient)
        ops.from = EthereumAddress(self.address)
        ops.gasPrice = .manual(BigUInt(stringLiteral: gasPrice))
        ops.gasLimit = .manual(BigUInt(stringLiteral: gasLimit))
        ops.callOnBlock = .latest
        
        let _value = _nonce * zzzzz

        var transaction = EthereumTransaction(type: .legacy, to: EthereumAddress(recipient)!, nonce: _nonce, chainID: WalletService.share.bigChainID, value: _value, data: payload.sc_hex2data, v: BigUInt(0), r: BigUInt(0), s: BigUInt(0), parameters: EthereumParameters(from: ops))
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
