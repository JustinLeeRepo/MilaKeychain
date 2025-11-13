// The Swift Programming Language
// https://docs.swift.org/swift-book
// https://www.youtube.com/watch?v=cQjgBIJtMbw

import Foundation

public class Keychain: Keychainable {
    init() {
        
    }

    public func update(id: String, stringData: String) throws {
        guard let data = stringData.data(using: .utf8) else { throw KeychainError.invalidData }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: id
        ]
        
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
        if updateStatus != errSecSuccess {
            try add(id: id, data: data)
        }
    }
    
    private func add(id: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: id,
            kSecValueData as String: data
        ]
        
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw KeychainError.saveFailed }
    }

    public func get(id: String) throws -> String {
        guard let data = try? data(id: id) else { throw KeychainError.itemNotFound }
        guard let value = String(data: data, encoding: .utf8) else { throw KeychainError.invalidData }
        
        return value
    }

    private func data(id: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: id,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard status == errSecSuccess else { throw KeychainError.retrievalFailed }
        guard let resultData = result as? Data else { throw KeychainError.invalidData }

        return resultData
    }

    public func delete(id: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: id
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.deleteFailed }
    }
}
