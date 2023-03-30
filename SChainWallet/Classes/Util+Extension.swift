//
//  Util+Extension.swift
//  SChainWallet
//
//  Created by lt on 2023/3/29.
//

import Foundation

public typealias JSONObject = [String: Any]
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

    var sc_hex2data: Data {
        return Data(hex: self)
    }

    var sc_toJson: JSONObject? {
        let d = self.data(using: .utf8)
        if let ret = try? JSONSerialization.jsonObject(with: d ?? Data()) as? JSONObject {
            return ret
        }
        return nil
    }
}
