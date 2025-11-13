//
//  Keychainable.swift
//  MilaKeychain
//
//  Created by Justin Lee on 11/12/25.
//

import Foundation

public protocol Keychainable {
    func update(id: Keychain.Identifier, stringData: String) throws
    func get(id: Keychain.Identifier) throws -> String
    func delete(id: Keychain.Identifier) throws
}
