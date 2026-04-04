import Foundation
import Security

// MARK: - Protocol

protocol KeychainServiceProtocol {
    /// Store an API key in the keychain for the given reference ID.
    func store(apiKey: String, forReference reference: String) throws
    /// Retrieve the API key for the given reference ID, or nil if not found.
    func retrieve(forReference reference: String) -> String?
    /// Delete the API key for the given reference ID.
    func delete(forReference reference: String) throws
    /// Update an existing API key for the given reference ID.
    func update(apiKey: String, forReference reference: String) throws
}

// MARK: - Errors

enum KeychainError: Error, Equatable {
    case duplicateEntry
    case itemNotFound
    case unexpectedStatus(OSStatus)
}

// MARK: - Live Implementation

final class LiveKeychainService: KeychainServiceProtocol {
    private let serviceName = "com.indraft.apikeys"

    func store(apiKey: String, forReference reference: String) throws {
        guard let data = apiKey.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: reference,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func retrieve(forReference reference: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: reference,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func delete(forReference reference: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: reference
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func update(apiKey: String, forReference reference: String) throws {
        guard let data = apiKey.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: reference
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

// MARK: - Mock Implementation

final class MockKeychainService: KeychainServiceProtocol {
    private var storage: [String: String] = [:]

    func store(apiKey: String, forReference reference: String) throws {
        guard storage[reference] == nil else {
            throw KeychainError.duplicateEntry
        }
        storage[reference] = apiKey
    }

    func retrieve(forReference reference: String) -> String? {
        storage[reference]
    }

    func delete(forReference reference: String) throws {
        storage.removeValue(forKey: reference)
    }

    func update(apiKey: String, forReference reference: String) throws {
        guard storage[reference] != nil else {
            throw KeychainError.itemNotFound
        }
        storage[reference] = apiKey
    }
}
