//
//  ViewController.swift
//  SChainWallet
//
//  Created by 3839147 on 03/28/2023.
//  Copyright (c) 2023 3839147. All rights reserved.
//

import SChainWallet
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        return
        let password = "123456"
        let mnemonics = "situate injury abstract vendor install spend venture color pledge cradle liar toast"
        let privateKey = "6c6b69d230f643a880fbe6825aff39efd00a88cc7cd3609343f2d9ff6c5f6454"
        
        let wallet = WalletManager.mnemonicsToWallet(mnemonics: mnemonics, password: password)
        print(wallet)
        
        let wallet2 = WalletManager.privateKeyToWallet(privateKey: privateKey, password: password)
        print(wallet2)
        
        let pk = WalletManager.mnemonicsToPrivateKey(rawMnemonics: mnemonics)
        
        assert(privateKey == pk, "error")
        
        let ret = wallet2?.save()
        print(ret)
        
        do {
            let mn = try wallet?.exportWallet(password: password)
            assert(mn == mnemonics, "error")
            
            let pk2 = try wallet2?.exportWallet(password: password)
            assert(pk2 == privateKey, "error")
        } catch {}
    }

    @IBAction func call(_ sender: Any) {}
    
    @IBAction func sendTransaction(_ sender: Any) {
        let privateKey = "d7234b49aaa8c62a883cb23657a52b4b30e65c062f0ea04b38d08b3592f80aab"
        let password = "123456"
        let from = "0x19B6e621a088749dedb3425A03A90Ec5b65e9D26"
        let to = "0x203080E21D157C56BFA30aa01716D632F5247546"
        let wallet = WalletManager.privateKeyToWallet(privateKey: privateKey, password: password)
        wallet?.save()
        
        if let rsp = WalletService.getTransactionCount(address: from), let data = rsp.data,  let nonce = data?.description {
            let tx = wallet?.signTransaction(recipient: to, value: "1", nonce: nonce, gasLimit: "9000000", gasPrice: "4100000000", payload: "", password: password)
            debugPrint(tx)
        }
        
        let ret = wallet?.personalSign(message: "This is a test data", password: password)
        debugPrint(ret)
        
        let getDptBatchBalance = WalletService.getDptBatchBalance(contractAddress: "0x13cbf419621a8A02f39228523D3CEeF203A15421", walletAddress: from, batchNo: "THC2023032809")
        debugPrint(getDptBatchBalance)
        
        let isCyWhiteList = WalletService.isCyWhiteList(address: from)
        debugPrint(isCyWhiteList)
        
        let isCyBlacklist = WalletService.isCyBlacklist(address: from)
        debugPrint(isCyBlacklist)
        
        
        let balance = WalletService.getDptBalance(contractAddress: "0x13cbf419621a8A02f39228523D3CEeF203A15421", walletAddress: from)
        debugPrint(balance)
        let l = IntegralToken(tokenName: "THC2023032809", tokenAddress: "0x13cbf419621a8A02f39228523D3CEeF203A15421", points: 1)

//        批次号是jstin00002
//        let result =

        let l1 = IntegralToken(tokenName: "P-DPT", tokenAddress: "0x166F1305cF4534b2c3b57DB9449C170F7eE6e29c", points: 1)

        DispatchQueue.global().async {
            
            let result = WalletService.pointAggregationTransaction(walletPassword: password, walletAddress: from, toAddress: to, dptContractList: [l])
            
            print(result)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
