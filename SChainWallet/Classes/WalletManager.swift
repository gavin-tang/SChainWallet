import CryptoSwift
import Foundation
import HandyJSON
import web3swift

extension String {
    static let sc_hexFlag: String = "0x"

    var sc_password: String {
        let this = self.sha256()
        return String(this.dropLast(this.count - 32))
    }

    var sc_iv: String {
        let this = self.sha256()
        return String(this.dropLast(this.count - 16))
    }

    var sc_dropHex: String {
        let this = self
        if this.hasPrefix(String.sc_hexFlag) {
            return String(this.dropFirst(2))
        }
        return this
    }

    var sc_hasHex: Bool {
        return self.hasPrefix(String.sc_hexFlag)
    }

    var sc_addHex: String {
        let this = self
        if this.hasPrefix(String.sc_hexFlag) {
            return this
        }
        return String.sc_hexFlag + this
    }
}

public final class WalletManager {
    static let shared = WalletManager()
}

public typealias JSONObject = [String: Any]

public extension WalletManager {
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

    static func privateKeyToWallet(privateKey: String, password: String) -> Wallet? {
        do {
            let aes = try AES(key: password.sc_password, iv: "Wallet".sc_iv)
            let cryptResult = try aes.encrypt(Array(privateKey.utf8))

            let privateData = Data(hex: privateKey.sc_dropHex)

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
