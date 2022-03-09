//
//  Store.swift
//  AdirApp
//
//  Created by iMac1 on 18.11.2021.
//

import Foundation

public protocol SimpleStore {
    /// Sets value for given key in this store. If value is nil then value is removed.
    ///
    /// - Parameters:
    ///   - value: Value to be saved
    ///   - key: Key
    func setValue(_ value: Any?, forKey key: String)

    /// Reads value for given key from this store.
    ///
    /// - Parameter key: Key
    /// - Returns: Value for given key. If no value for key is found nil is returned.
    func value(forKey key: String) -> Any?

    /// Reads data for given key from this store.
    ///
    /// - Parameter key: Key
    /// - Returns: Data for given key. If no value for key is found nil is returned.
    func data(forKey key: String) -> Data?
}

// MARK: - Store

enum Store {
    static let standard: SimpleStore = DefaultsStore()
}

// MARK: - DefaultsStore

class DefaultsStore: SimpleStore {
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }

    func setValue(_ value: Any?, forKey key: String) {
        if let value = value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }

    func value(forKey key: String) -> Any? {
        if let val = defaults.value(forKey: key) {
            return val
        }
        return nil
    }

    func data(forKey key: String) -> Data? {
        if let val = defaults.data(forKey: key) {
            return val
        }
        return nil
    }
}
