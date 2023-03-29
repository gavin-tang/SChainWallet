import XCTest
//import SChainWallet

class Tests: XCTestCase {
    
    let password = "123456"
    let mnemonics = "situate injury abstract vendor install spend venture color pledge cradle liar toast"
    let privateKey = "xprv9yJkCNrr5jnwKTLgf94gMfAV1FeNs8gDw17Dq1TdVA3c7pS5CFTkVfyzPa5Xoew83N9ZtW4c61pGXez4nMZVZESe8q8JDCdWoTmb3zcGDnG"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let wallet = try WalletManager.mnemonicsToWallet(mnemonics: mnemonics, password: password)
//        print(wallet)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
