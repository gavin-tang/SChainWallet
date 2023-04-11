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

public struct IntegralToken {
    public var tokenName: String
    public var tokenAddress: String
    public var points: Int64
    public init(tokenName: String, tokenAddress: String, points: Int64) {
        self.tokenName = tokenName
        self.tokenAddress = tokenAddress
        self.points = points
    }
}

public extension WalletService {
    /// 多积分转账合约
    static let Transfer_Contract_Address = "0x9C5c0AC582802eed9f1857A53e0eda06EE0Dc482"
    /// 积分合约
    static let Sub_Token_Balance_Contract_Address = "0xFD2be2cEa326B6484D3C154F58384de65292C792"
    /// 白名单、黑名单合约地址
    static let WhiteBlacklist_Contract_Address = "0x28D9b238847057eBD024FBECF6633689d897B819"
    static let queryTokenABI = """
    [{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"inputs":[{"internalType":"address[]","name":"tokens","type":"address[]"},{"internalType":"address[]","name":"accounts","type":"address[]"},{"internalType":"uint256[]","name":"ids","type":"uint256[]"}],"name":"balanceOfBatchAll","outputs":[{"internalType":"uint256[]","name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_center","type":"address"}],"name":"init","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"limitedBatch","outputs":[{"internalType":"bool[]","name":"","type":"bool[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"tokens","type":"address[]"},{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"overallBalanceBatchAll","outputs":[{"internalType":"uint256[]","name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"whitelistBatch","outputs":[{"internalType":"bool[]","name":"","type":"bool[]"}],"stateMutability":"view","type":"function"}]
    """
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
    
    /// 积分转账合约
    var transferContract: web3.web3contract? {
        let query = """
        [{"inputs":[{"internalType":"address","name":"_from","type":"address"},{"internalType":"address","name":"_to","type":"address"},{"internalType":"address[]","name":"_targets","type":"address[]"},{"internalType":"uint256[]","name":"_tokenids","type":"uint256[]"},{"internalType":"uint256[]","name":"_amount","type":"uint256[]"}],"name":"proxyTransfer","outputs":[],"stateMutability":"nonpayable","type":"function"}]
        """
        let contract = w3?.contract(query, at: EthereumAddress(WalletService.Transfer_Contract_Address)!, abiVersion: 2)
        return contract
    }
    
    /// 积分余额
    var queryContract: web3.web3contract? {
        let contract = w3?.contract(WalletService.queryTokenABI, at: EthereumAddress(WalletService.Sub_Token_Balance_Contract_Address)!, abiVersion: 2)
        return contract
    }

    /// 黑白名单合约
    var blackwhiteContract: web3.web3contract? {
        let query = """
        [{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"bool","name":"isAdd","type":"bool"}],"name":"Blacklist","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"}],"name":"GovernorAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"account","type":"address"}],"name":"GovernorRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"bool","name":"isAdd","type":"bool"}],"name":"Whitelist","type":"event"},{"inputs":[{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"addAccount","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_account","type":"address"}],"name":"addGovernor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"}],"name":"init","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_account","type":"address"}],"name":"isGovernor","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"isLimited","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"isWhitelist","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"removeAccount","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_account","type":"address"}],"name":"removeGovernor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceGovernor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"whitelistAdd","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"accounts","type":"address[]"}],"name":"whitelistRemove","outputs":[],"stateMutability":"nonpayable","type":"function"}]
        """
        let contract = w3?.contract(query, at: EthereumAddress(WalletService.WhiteBlacklist_Contract_Address)!, abiVersion: 2)
        return contract
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
    static func call(from: String, to: String, data: String) -> WalletResponse<String?> {
        return share.call(from: from, to: to, data: data)
    }
    
    static func shotdown() {}
    
    /// 获取原始代币余额
    static func getNativeTokenBalance(address: String) -> WalletResponse<BigUInt?>? {
        return share.getNativeTokenBalance(address: address)
    }
    
    /// 获取交易随机数
    static func getTransactionCount(address: String) -> WalletResponse<BigUInt?>? {
        return share.getTransactionCount(address: address)
    }
    
    /// 查询积分余额
    static func getDptBalance(contractAddress: String, walletAddress: String) -> WalletResponse<BigUInt?>? {
        return share.getDptBalance(contractAddress: contractAddress, walletAddress: walletAddress)
    }
    
    /// 获取积分合约单个批次余额
    static func getDptBatchBalance(contractAddress: String, walletAddress: String, batchNo: String) -> WalletResponse<BigUInt?>? {
        return share.getDptBatchBalance(contractAddress: contractAddress, walletAddress: walletAddress, batchNo: batchNo)
    }
    
    /// 查询钱包地址是否在畅由体系内
    static func isCyWhiteList(address: String) -> WalletResponse<Bool?>? {
        return share.isCyWhiteList(address: address)
    }
    
    /// 查询钱包地址是否黑名单
    static func isCyBlacklist(address: String) -> WalletResponse<Bool?>? {
        return share.isCyBlacklist(address: address)
    }

    /// 多积分转账
    static func pointAggregationTransaction(walletPassword: String, walletAddress: String, toAddress: String, dptContractList: [IntegralToken]) -> WalletResponse<String?>? {
        return share.pointAggregationTransaction(walletPassword: walletPassword, walletAddress: walletAddress, toAddress: toAddress, dptContractList: dptContractList)
    }
}

extension WalletService {
    func getGasPrice() -> BigUInt? {
        do {
            let w3 = WalletService.share.w3
            let gasPrice = try w3?.eth.getGasPricePromise().wait()
            debugPrint("gasPrice", gasPrice as Any)
            return gasPrice
        } catch {
            debugPrint("gasPrice", error)
        }
        return nil
    }
    
    func getNativeTokenBalance(address: String) -> WalletResponse<BigUInt?>? {
        do {
            let w3 = WalletService.share.w3
            let balance = try w3?.eth.getBalance(address: EthereumAddress(address)!)
            return WalletResponse(data: balance, error: nil)
        } catch {
            debugPrint(error)
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
    }
    
    func getTransactionCount(address: String) -> WalletResponse<BigUInt?>? {
        do {
            let w3 = WalletService.share.w3
            let nonce = try w3?.eth.getTransactionCount(address: EthereumAddress(address)!)
            return WalletResponse(data: nonce, error: nil)
        } catch {
            debugPrint(error)
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
    }
    
    func getDptBatchBalance(contractAddress: String, walletAddress: String, batchNo: String) -> WalletResponse<BigUInt?>? {
        guard let contract = w3?.contract(Web3Utils.erc1155ABI, at: EthereumAddress(contractAddress)!, abiVersion: 2) else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get gasPrice fail"))
        }
        
        do {
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.callOnBlock = .latest
            let result = try contract.read("balanceOf", parameters: [EthereumAddress(walletAddress)!, batchNo.sc_hex210BigUInt!] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call(transactionOptions: transactionOptions)
            guard let res = result["0"] as? BigUInt else {
                return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "unkown error"))
            }
            return WalletResponse(data: res)
        } catch {
            debugPrint(error)
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
    }
    
    func isCyWhiteList(address: String) -> WalletResponse<Bool?>? {
        guard let contract = WalletService.share.blackwhiteContract else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get gasPrice fail"))
        }
        
        do {
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.callOnBlock = .latest
            let result = try contract.read("isWhitelist", parameters: [EthereumAddress(address)!] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call(transactionOptions: transactionOptions)
            if let res = result["0"] as? Bool {
                return WalletResponse(data: res)
            }
        } catch {
            debugPrint(error)
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
        return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "unkown error"))
    }
    
    func isCyBlacklist(address: String) -> WalletResponse<Bool?>? {
        guard let contract = WalletService.share.blackwhiteContract else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get gasPrice fail"))
        }
        
        do {
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.callOnBlock = .latest
            let result = try contract.read("isLimited", parameters: [EthereumAddress(address)!] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call(transactionOptions: transactionOptions)
            if let res = result["0"] as? Bool {
                return WalletResponse(data: res)
            }
        } catch {
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
        
        return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "unkown error"))
    }
    
    /// 申请原生代币
    func applyTransfer(address: String) -> Bool {
        let request = AF.request("http://172.16.2.180:5111/ApplyTransfer", method: .post, parameters: ["WalletAddress": address])
        let promise = Promise<JSONObject> { resolver in
            request.responseString { response in
                debugPrint(response.value as Any)
                if let value = response.value, let tx = value.sc_toJson?["data"] as? JSONObject {
                    resolver.fulfill(tx)
                } else if let error = response.error {
                    resolver.reject(error)
                } else {
                    resolver.reject(CyError(errorCode: -1, errorMsg: "unkown error"))
                }
            }
        }
        
        do {
            let json = try promise.wait()
            if let Response = json["Response"] as? JSONObject, let status = Response["Status"] as? String, status == "200" {
                return true
            }
        } catch {}
        
        return false
    }
    
    func getDptBalance(contractAddress: String, walletAddress: String) -> WalletResponse<BigUInt?>? {
        guard let contract = WalletService.share.queryContract else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get gasPrice fail"))
        }
        
        do {
            var transactionOptions = TransactionOptions.defaultOptions
            transactionOptions.callOnBlock = .latest
            let result = try contract.read("overallBalanceBatchAll", parameters: [[EthereumAddress(contractAddress)], [EthereumAddress(walletAddress)!]] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)!.call(transactionOptions: transactionOptions)
            guard let res = result["0"] as? [Any], res.count > 0, let ret = res[0] as? BigUInt else {
                return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "unkown error"))
            }
            return WalletResponse(data: ret)
        } catch {
            debugPrint(error)
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
    }
    
    func pointAggregationTransaction(walletPassword: String, walletAddress: String, toAddress: String, dptContractList: [IntegralToken]) -> WalletResponse<String?>? {
        guard let privateData = Wallet.current?.exportPrivateWallet(password: walletPassword)?.sc_hex2data else {
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: "error wallet"))
        }
        
        guard let balance = getNativeTokenBalance(address: walletAddress)?.data else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get balance fail"))
        }

        let zzzzz = BigUInt(1000000000000000000)
        if balance! < zzzzz {
            let rst = applyTransfer(address: walletAddress)
            if rst == false {
                return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get balance fail"))
            }
        }
        
        guard let nonce = getTransactionCount(address: walletAddress)?.data else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get transaction count fail"))
        }
        
        guard let gasPrice = getGasPrice() else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "get gasPrice fail"))
        }
        
        guard let contract = WalletService.share.transferContract else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "contract fail"))
        }
        
        let from = EthereumAddress(walletAddress)!
        let to = EthereumAddress(toAddress)!
        let batches = dptContractList
        
        var opt = TransactionOptions.defaultOptions
        opt.chainID = bigChainID
        opt.gasPrice = .manual(gasPrice)
        opt.gasLimit = .limited(BigUInt(9000000))
        opt.callOnBlock = .latest
        opt.nonce = .manual(nonce!)
        opt.from = from
        opt.to = to
        let data = Data()
        var ids: [BigUInt] = []
        var values: [BigUInt] = []
        var addresses: [EthereumAddress] = []
        for item in batches {
            if item.points == 0 { continue }
            ids.append(item.tokenName.sc_hex210BigUInt!)
            values.append(BigUInt(item.points))
            addresses.append(EthereumAddress(item.tokenAddress)!)
        }
        guard let contractTx = contract.write("proxyTransfer", parameters: [from, to, addresses, ids, values] as [AnyObject], extraData: data, transactionOptions: opt) else {
            return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "Transaction generation failed"))
        }
        
        contractTx.transactionOptions.from = from
        contractTx.transactionOptions.value = 0

        opt.to = EthereumAddress(WalletService.Transfer_Contract_Address)!
        var transaction = EthereumTransaction(type: .legacy, to: EthereumAddress(WalletService.Transfer_Contract_Address)!, nonce: nonce!, chainID: bigChainID, value: BigUInt(0), data: contractTx.transaction.data, v: BigUInt(0), r: BigUInt(0), s: BigUInt(0), parameters: EthereumParameters(from: opt))
        
        do {
            transaction.applyOptions(opt)
            transaction.chainID = bigChainID
            transaction.unsign()
            try? transaction.sign(privateKey: privateData)
            
            if let result = try w3?.eth.sendRawTransaction(transaction) {
                return WalletResponse(data: result.hash)
            }
        } catch {
            debugPrint(error)
            return WalletResponse(error: CyError(errorCode: -1, errorMsg: error.localizedDescription))
        }
        return WalletResponse(data: nil, error: CyError(errorCode: -1, errorMsg: "unkown error"))
    }
    
    func call(from: String, to: String, data: String) -> WalletResponse<String?> {
        let params = ["jsonrpc": "2.0", "method": "eth_call", "id": 1, "params": [["from": from, "to": to, "data": data] as [String: Any], "latest"]] as [String: Any]
        let request = AF.request(rpcURL, method: .post, parameters: params)
        
        let promise = Promise<String> { resolver in
            request.responseString { response in
                debugPrint(response.value as Any)
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
