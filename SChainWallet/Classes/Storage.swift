//
//  Storage.swift
//  SChainWallet
//
//  Created by lt on 2023/3/28.
//

import Foundation

private let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString

class Storage {
    static let shared = Storage()

    // MARK: 移除path下所有数据

    func removeAll(filePath: String) -> Bool {
        let filePath = path.appendingPathComponent(filePath)
        guard FileManager.default.fileExists(atPath: filePath) else {
            return true
        }
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch _ {
            return false
        }
    }

    // MARK: - 解档归档(保存的是String数组)

    // 归档
    func archiveWithStringArray(channel: [String], appendPath: String) {
        let filePath = path.appendingPathComponent(appendPath)
        NSKeyedArchiver.archiveRootObject(channel, toFile: filePath)
    }

    // 反归档
    func unarchiveToStringArray(appendPath: String) -> ([String]?) {
        let filePath = path.appendingPathComponent(appendPath)
        return NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String]
    }

    // MARK: - 解档归档(保存的是任意对象数组)

    func archive<T: Codable>(array: [T], appendPath: String) -> Bool {
        let filePath = path.appendingPathComponent(appendPath)
        if let data = try? PropertyListEncoder().encode(array) {
            return NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
        }
        return false
    }

    func unarchive<T: Codable>(appendPath: String, _ obj: T.Type) -> [T]? {
        let filePath = path.appendingPathComponent(appendPath)
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data, let obj = try? PropertyListDecoder().decode([T].self, from: data) {
            return obj
        }
        return nil
    }

    // MARK: - 解档归档(保存的是字典)

    func archive(dictionary: NSDictionary, appendPath: String) -> Bool {
        let filePath = path.appendingPathComponent(appendPath)
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            return NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
        }
        return false
    }

    func unarchiveToDictionary(appendPath: String) -> Any? {
        let filePath = path.appendingPathComponent(appendPath)
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data {
            return try? JSONSerialization.jsonObject(with: data, options: [])
        }
        return nil
    }
}
