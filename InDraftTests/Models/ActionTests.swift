import XCTest
import SwiftData
@testable import InDraft

final class ActionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Field Defaults

    func testActionCreatedWithDefaults() {
        let action = Action(name: "Test", prompt: "Do something")
        context.insert(action)
        try! context.save()

        XCTAssertFalse(action.id.uuidString.isEmpty)
        XCTAssertEqual(action.name, "Test")
        XCTAssertEqual(action.prompt, "Do something")
        XCTAssertNil(action.hotkeyKeyCode)
        XCTAssertNil(action.hotkeyModifiers)
        XCTAssertEqual(action.outputBehavior, .replace)
        XCTAssertEqual(action.providerMode, .active)
        XCTAssertNil(action.providerID)
        XCTAssertNil(action.modelOverride)
        XCTAssertTrue(action.enabled)
        XCTAssertEqual(action.sortOrder, 0)
    }

    func testActionWithAllFields() {
        let providerID = UUID()
        let action = Action(
            name: "Custom",
            prompt: "Translate to English",
            hotkeyKeyCode: 18,
            hotkeyModifiers: 0x040000 | 0x080000,
            outputBehavior: .preview,
            providerMode: .fixed,
            providerID: providerID,
            modelOverride: "gpt-4o",
            enabled: false,
            sortOrder: 5
        )
        context.insert(action)
        try! context.save()

        XCTAssertEqual(action.outputBehavior, .preview)
        XCTAssertEqual(action.providerMode, .fixed)
        XCTAssertEqual(action.providerID, providerID)
        XCTAssertEqual(action.modelOverride, "gpt-4o")
        XCTAssertFalse(action.enabled)
        XCTAssertEqual(action.sortOrder, 5)
    }

    // MARK: - Hotkey Display

    func testHasHotkeyWhenSet() {
        let action = Action(name: "Test", prompt: "Prompt", hotkeyKeyCode: 18, hotkeyModifiers: 0)
        XCTAssertTrue(action.hasHotkey)
    }

    func testHasHotkeyWhenNil() {
        let action = Action(name: "Test", prompt: "Prompt")
        XCTAssertFalse(action.hasHotkey)
    }

    // MARK: - Output Behavior Enum

    func testOutputBehaviorCases() {
        XCTAssertEqual(OutputBehavior.allCases.count, 3)
        XCTAssertTrue(OutputBehavior.allCases.contains(.replace))
        XCTAssertTrue(OutputBehavior.allCases.contains(.preview))
        XCTAssertTrue(OutputBehavior.allCases.contains(.clipboard))
    }

    // MARK: - Provider Mode Enum

    func testProviderModeCases() {
        XCTAssertEqual(ProviderMode.allCases.count, 2)
        XCTAssertTrue(ProviderMode.allCases.contains(.active))
        XCTAssertTrue(ProviderMode.allCases.contains(.fixed))
    }

    // MARK: - Persistence

    func testActionPersistsAndFetches() throws {
        let action = Action(name: "Persist Test", prompt: "Some prompt", sortOrder: 1)
        context.insert(action)
        try context.save()

        let descriptor = FetchDescriptor<Action>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Persist Test")
    }

    func testMultipleActionsWithSortOrder() throws {
        let a1 = Action(name: "First", prompt: "P1", sortOrder: 0)
        let a2 = Action(name: "Second", prompt: "P2", sortOrder: 1)
        let a3 = Action(name: "Third", prompt: "P3", sortOrder: 2)
        context.insert(a1)
        context.insert(a2)
        context.insert(a3)
        try context.save()

        var descriptor = FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)])
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 3)
        XCTAssertEqual(fetched[0].name, "First")
        XCTAssertEqual(fetched[1].name, "Second")
        XCTAssertEqual(fetched[2].name, "Third")
    }
}
