import XCTest
@testable import InDraft

final class KeychainServiceTests: XCTestCase {
    var sut: MockKeychainService!

    override func setUp() {
        super.setUp()
        sut = MockKeychainService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Store & Retrieve

    func testStoreAndRetrieveAPIKey() throws {
        let reference = "provider-openai-key"
        let apiKey = "sk-test-1234567890"

        try sut.store(apiKey: apiKey, forReference: reference)
        let retrieved = sut.retrieve(forReference: reference)

        XCTAssertEqual(retrieved, apiKey)
    }

    // MARK: - Retrieve Non-Existent

    func testRetrieveNonExistentKeyReturnsNil() {
        let retrieved = sut.retrieve(forReference: "does-not-exist")
        XCTAssertNil(retrieved)
    }

    // MARK: - Update

    func testUpdateExistingKey() throws {
        let reference = "provider-anthropic-key"
        try sut.store(apiKey: "old-key", forReference: reference)

        try sut.update(apiKey: "new-key", forReference: reference)
        let retrieved = sut.retrieve(forReference: reference)

        XCTAssertEqual(retrieved, "new-key")
    }

    func testUpdateNonExistentKeyThrows() {
        XCTAssertThrowsError(try sut.update(apiKey: "key", forReference: "missing")) { error in
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }
    }

    // MARK: - Delete

    func testDeleteExistingKey() throws {
        let reference = "provider-delete-me"
        try sut.store(apiKey: "temp-key", forReference: reference)

        try sut.delete(forReference: reference)
        let retrieved = sut.retrieve(forReference: reference)

        XCTAssertNil(retrieved)
    }

    func testDeleteNonExistentKeyDoesNotThrow() {
        XCTAssertNoThrow(try sut.delete(forReference: "never-existed"))
    }

    // MARK: - Duplicate Store

    func testStoreDuplicateKeyThrows() throws {
        let reference = "dup-key"
        try sut.store(apiKey: "first", forReference: reference)

        XCTAssertThrowsError(try sut.store(apiKey: "second", forReference: reference)) { error in
            XCTAssertEqual(error as? KeychainError, .duplicateEntry)
        }
    }

    // MARK: - Protocol Conformance

    func testMockConformsToProtocol() {
        let service: KeychainServiceProtocol = MockKeychainService()
        XCTAssertNil(service.retrieve(forReference: "any"))
    }

    func testLiveConformsToProtocol() {
        let service: KeychainServiceProtocol = LiveKeychainService()
        XCTAssertNotNil(service)
    }
}
