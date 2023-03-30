//
//  WalletService.swift
//  SChainWallet
//
//  Created by lt on 2023/3/30.
//

import Alamofire
import BigInt
import Foundation
import PromiseKit
import web3swift

public struct CyError: Error {
    var errorCode: Int?
    var errorMsg: String?
}

public struct WalletResponse<T> {
    var data: T?
    var error: CyError?
}

public class WalletService {
    internal static let share = WalletService()
    var rpcURL: URL = .init(string: "https://baidu.com")!
    var chainID: Int = 22
    var bigChainID: BigUInt = .init(22)
    var networks: Networks?

    init() {}

    init(rpcURL: URL, chainID: Int, networks: Networks? = nil) {
        self.rpcURL = rpcURL
        self.chainID = chainID
        self.networks = networks
    }
}

extension WalletService {
    var w3: web3? {
        if let provider = Web3HttpProvider(rpcURL, network: networks) {
            return web3(provider: provider)
        }
        assertionFailure("error")
        return nil
    }
}

public extension WalletService {
    static func build(url: URL, chainID: Int) {
        WalletService.share.rpcURL = url
        WalletService.share.chainID = chainID
        WalletService.share.bigChainID = BigUInt(chainID)
        WalletService.share.networks = Networks.Custom(networkID: BigUInt(chainID))
    }
}

public extension WalletService {
    func call(from: String, to: String, data: String) -> WalletResponse<String?> {
        let params = ["jsonrpc": "2.0", "method": "eth_call", "id": 1, "params": [["from": from, "to": to, "data": data] as [String: Any], "latest"]] as [String: Any]
        let request = AF.request(rpcURL, method: .post, parameters: params)

        let promise = Promise<String> { resolver in
            request.responseString { response in
                debugPrint(response.value)
                if let value = response.value, let tx = value.sc_toJson?["data"] as? String {
                    resolver.fulfill(tx)
                } else if let error = response.error {
                    resolver.reject(error)
                } else {
                    resolver.reject(CyError(errorCode: -1, errorMsg: "unkown error"))
                }
            }
        }

        var tx: String?
        var err: CyError?
        do {
            tx = try promise.wait()
        } catch {
            err = error as? CyError
        }
        return WalletResponse<String?>(data: tx, error: err)
    }
}
