import XCTest
@testable import InDraft

/// Tests that verify the Keychain integration pattern used by ProviderEditorView.
/// Since ProviderEditorView is a SwiftUI view and hard to unit test directly,
/// these tests verify the KeychainService operations that the view relies on.
@MainActor
final class ProviderEditorKeychainTests: XCTestCase {

    var keychain: MockKeychainService!

    override func setUp() {
        super.setUp()
        keychain = MockKeychainService()
    }

    // MARK: - New Provider Flow

    func testNewProviderStoresKeyInKeychain() throws {
        let reference = "provider-\(UUID().uuidString)"
        let apiKey = "sk-test-key-12345"

        try keychain.store(apiKey: apiKey, forReference: reference)

        let retrieved = keychain.retrieve(forReference: reference)
        XCTAssertEqual(retrieved, apiKey)
    }

    func testNewProviderReferenceIsNotTheRawKey() {
        let reference = "provider-\(UUID().uuidString)"
        let apiKey = "sk-test-key-12345"

        try? keychain.store(apiKey: apiKey, forReference: reference)

        // The reference should NOT be the API key itself
        XCTAssertNotEqual(reference, apiKey)
        XCTAssertTrue(reference.hasPrefix("provider-"))
    }

    // MARK: - Edit Provider Flow

    func testExistingProviderUpdatesKeyInKeychain() throws {
        let reference = "provider-existing-ref"
        try keychain.store(apiKey: "old-key", forReference: reference)

        try keychain.update(apiKey: "new-key", forReference: reference)

        let retrieved = keychain.retrieve(forReference: reference)
        XCTAssertEqual(retrieved, "new-key")
    }

    func testExistingProviderWithMissingKeychainEntryRecovers() throws {
        let reference = "provider-lost-ref"

        // Keychain entry was lost — update should throw itemNotFound
        XCTAssertThrowsError(try keychain.update(apiKey: "key", forReference: reference)) { error in
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }

        // Recovery: store instead
        try keychain.store(apiKey: "key", forReference: reference)
        XCTAssertEqual(keychain.retrieve(forReference: reference), "key")
    }

    // MARK: - Load Provider Flow

    func testLoadProviderRetrievesKeyFromKeychain() throws {
        let reference = "provider-load-ref"
        let apiKey = "sk-actual-secret-key"
        try keychain.store(apiKey: apiKey, forReference: reference)

        let retrieved = keychain.retrieve(forReference: reference)
        XCTAssertEqual(retrieved, apiKey)
    }

    func testLoadProviderWithEmptyReferenceReturnsNil() {
        let retrieved = keychain.retrieve(forReference: "")
        XCTAssertNil(retrieved)
    }

    func testLoadProviderWithMissingKeychainEntryReturnsNil() {
        let retrieved = keychain.retrieve(forReference: "provider-nonexistent")
        XCTAssertNil(retrieved)
    }

    // MARK: - Delete Provider Flow

    func testDeleteProviderCleansUpKeychain() throws {
        let reference = "provider-delete-ref"
        try keychain.store(apiKey: "key-to-delete", forReference: reference)
        XCTAssertNotNil(keychain.retrieve(forReference: reference))

        try keychain.delete(forReference: reference)
        XCTAssertNil(keychain.retrieve(forReference: reference))
    }

    func testDeleteProviderWithMissingKeychainEntryDoesNotThrow() {
        // Should not throw even if entry doesn't exist
        XCTAssertNoThrow(try keychain.delete(forReference: "provider-already-gone"))
    }
}
