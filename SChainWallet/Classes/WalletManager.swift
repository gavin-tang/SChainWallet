import Foundation

public final class WalletManager {}
public extension WalletManager {
    /// 根据助记词生成钱包
    /// - Parameters:
    ///   - mnemonics: 助记词
    ///   - password: 加密密码
    /// - Returns: 钱包
    static func mnemonicsToWallet(mnemonics: String, password: String) -> Wallet? {
        return Wallet.mnemonicsToWallet(mnemonics: mnemonics, password: password)
    }

    /// 根据私钥生成钱包
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - password: 加密密码
    /// - Returns: 钱包
    static func privateKeyToWallet(privateKey: String, password: String) -> Wallet? {
        return Wallet.privateKeyToWallet(privateKey: privateKey, password: password)
    }

    /// 助记词转私钥
    /// - Parameter rawMnemonics: 助记词(未加密)
    /// - Returns: 若是合理的助记词则返回私钥，否则 nil
    static func mnemonicsToPrivateKey(rawMnemonics: String) -> String? {
        return Wallet.mnemonicsToPrivateKey(rawMnemonics: rawMnemonics)
    }

    /// 销毁钱包文件
    static func destroyWallet(address: String) -> Bool {
        return Wallet.removeWalletWithAddress(address: address)
    }

    /// 导出钱包私钥
    static func getWalletPrivateKey(address: String, password: String) -> String? {
        return Wallet.privateKeyWithAddress(address: address, password: password)
    }

    /// 生成交易签名
    static func signMsg(message: String, password: String) -> String? {
        return nil
    }
}
