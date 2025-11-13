// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

enum KeychainError: Error, LocalizedError {
    case invalidData
    case saveFailed
    case itemNotFound
    case retrievalFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Unable to form string from data using utf8"
            
        case .saveFailed:
            return "Unable to save to keychain"
            
        case .itemNotFound:
            return "Item cannot be found"
            
        case .retrievalFailed:
            return "Keychain retrieval failed"
            
        case .deleteFailed:
            return "Unable to delete from keychain"
        }
    }
}

// TODO: use protocol containing service: String?, accessGroup: String?
public class Keychain {
    public static let shared = Keychain()
    
    private init() {}

    public enum KeychainIdentifier: String {
        case authToken = "JustinLee.HSD.keys.authToken"
    }

    public func update(id: KeychainIdentifier, stringData: String) throws {
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
    
    private func add(id: KeychainIdentifier, data: Data) throws {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = id.rawValue
        query[kSecValueData as String] = data
        
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }

    public func get(id: KeychainIdentifier) throws -> String {

        guard let data = try? data(id: id) else {
            throw KeychainError.itemNotFound
        }

        guard let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return value
    }

    private func data(id: KeychainIdentifier) throws -> Data {
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

    public func delete(id: KeychainIdentifier) throws {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = id.rawValue
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}
