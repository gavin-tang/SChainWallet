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
    internal var rpcURL: URL = .init(string: "http://121.46.19.38:54701")!
    internal var chainID: Int = 123321 {
        didSet {
            bigChainID = BigUInt(chainID)
            networks = Networks.Custom(networkID: BigUInt(chainID))
        }
    }

    internal var bigChainID: BigUInt = .init(123321)
    internal var networks: Networks? = Networks.Custom(networkID: BigUInt(123321))

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
    static func build(url: URL, chainID: Int) -> WalletService {
        WalletService.share.rpcURL = url
        WalletService.share.chainID = chainID
        return WalletService.share
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

    func shotdown() {}

    func getNativeTokenBalance(address: String) -> BigUInt? {
        do {
            let w3 = WalletService.share.w3
            let balance = try w3?.eth.getBalance(address: EthereumAddress(address)!)
            return balance
        } catch {}

        return nil
    }

    func getTransactionCount(address: String) -> BigUInt? {
        do {
            let w3 = WalletService.share.w3
            let balance = try w3?.eth.getTransactionCount(address: EthereumAddress(address)!)
            return balance
        } catch {}

        return nil
    }

    func getDptBalance(contractAddress: String, walletAddress: String) -> [Any?]? {
        var params: JSONObject = [:]

//        params["Module"] = "Client"
//        params["Action"] = "GetPersonalPointList"
//        params["ContractAddress"] = contractAddress
//        params["WalletAddress"] = walletAddress
//        let request = AF.request(rpcURL, method: .post, parameters: params)

        return nil
    }

    func getDptBatchBalance(contractAddress: String, walletAddress: String, batchNo: String) -> WalletResponse<[Any?]?>? {
        return nil
    }

    func isCyWhiteList(address: String) -> WalletResponse<[Any?]?>? {
        return nil
    }

    func isCyBlacklist(address: String) -> WalletResponse<[Any?]?>? {
        return nil
    }

    func pointAggregationTransaction(walletPassword: String, walletAddress: String, toAddress: String, dptContractList: [Any]) -> WalletResponse<[Any?]?>?
    {
        return nil
    }
}
