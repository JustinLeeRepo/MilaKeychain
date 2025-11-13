//
//  Keychainable.swift
//  MilaKeychain
//
//  Created by Justin Lee on 11/12/25.
//

import Foundation

public protocol Keychainable {
    func update(id: String, stringData: String) throws
    func get(id: String) throws -> String
    func delete(id: String) throws
}
