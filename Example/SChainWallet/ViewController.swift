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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
