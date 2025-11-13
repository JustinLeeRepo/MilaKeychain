//
//  KeychainError.swift
//  MilaKeychain
//
//  Created by Justin Lee on 11/12/25.
//

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
