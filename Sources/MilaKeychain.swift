// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class Keychain: Keychainable {
    public enum Identifier: String {
        case authToken = "JustinLee.Mila.keys.authToken"
    }

    public func update(id: Identifier = .authToken, stringData: String) throws {
        guard let data = stringData.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = id.rawValue
        let updateAttributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
        
        if updateStatus != errSecSuccess {
            try add(id: id, data: data)
        }
    }
    
    private func add(id: Identifier, data: Data) throws {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = id.rawValue
        query[kSecValueData as String] = data
        
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }

    public func get(id: Identifier = .authToken) throws -> String {
        guard let data = try? data(id: id) else {
            throw KeychainError.itemNotFound
        }

        guard let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return value
    }

    private func data(id: Identifier) throws -> Data {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = id.rawValue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.retrievalFailed
        }
        
        guard let resultData = result as? Data else {
                throw KeychainError.invalidData
        }

        return resultData
    }

    public func delete(id: Identifier = .authToken) throws {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = id.rawValue
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}
