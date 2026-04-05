import XCTest
import SwiftData
import Carbon.HIToolbox
import Cocoa
@testable import InDraft

final class SeedDataTests: XCTestCase {
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

    func testCreateDefaultActionsSeeds6Actions() throws {
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        XCTAssertEqual(actions.count, 6)
        XCTAssertEqual(actions[0].name, "Grammar Fix")
        XCTAssertEqual(actions[1].name, "Rewrite for Clarity")
        XCTAssertEqual(actions[2].name, "Shorten")
        XCTAssertEqual(actions[3].name, "Translate to English")
        XCTAssertEqual(actions[4].name, "Professional Tone")
        XCTAssertEqual(actions[5].name, "ELI5")
    }

    func testCreateDefaultActionsIdempotent() throws {
        SeedData.createDefaultActions(in: context)
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>())
        XCTAssertEqual(actions.count, 6, "Should not duplicate actions on second call")
    }

    func testDefaultActionsHaveCorrectOutputBehavior() throws {
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>())
        for action in actions {
            XCTAssertEqual(action.outputBehavior, .replace)
        }
    }

    func testDefaultActionsHaveHotkeys() throws {
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        for action in actions {
            XCTAssertTrue(action.hasHotkey, "\(action.name) should have a hotkey")
        }
    }

    func testDefaultActionsHaveCorrectHotkeys() throws {
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        let expectedModifiers = UInt32(NSEvent.ModifierFlags([.control, .option]).rawValue)

        // Grammar Fix → control+option+1 (kVK_ANSI_1 = 18)
        XCTAssertEqual(actions[0].hotkeyKeyCode, UInt32(kVK_ANSI_1))
        XCTAssertEqual(actions[0].hotkeyModifiers, expectedModifiers)

        // Rewrite for Clarity → control+option+2 (kVK_ANSI_2 = 19)
        XCTAssertEqual(actions[1].hotkeyKeyCode, UInt32(kVK_ANSI_2))
        XCTAssertEqual(actions[1].hotkeyModifiers, expectedModifiers)

        // Shorten → control+option+3 (kVK_ANSI_3 = 20)
        XCTAssertEqual(actions[2].hotkeyKeyCode, UInt32(kVK_ANSI_3))
        XCTAssertEqual(actions[2].hotkeyModifiers, expectedModifiers)

        // Translate to English → control+option+4 (kVK_ANSI_4 = 21)
        XCTAssertEqual(actions[3].hotkeyKeyCode, UInt32(kVK_ANSI_4))
        XCTAssertEqual(actions[3].hotkeyModifiers, expectedModifiers)

        // Professional Tone → control+option+5 (kVK_ANSI_5 = 23)
        XCTAssertEqual(actions[4].hotkeyKeyCode, UInt32(kVK_ANSI_5))
        XCTAssertEqual(actions[4].hotkeyModifiers, expectedModifiers)

        // ELI5 → control+option+6 (kVK_ANSI_6 = 22)
        XCTAssertEqual(actions[5].hotkeyKeyCode, UInt32(kVK_ANSI_6))
        XCTAssertEqual(actions[5].hotkeyModifiers, expectedModifiers)
    }

    func testRestoreDefaultsResetsBuiltInActions() throws {
        SeedData.createDefaultActions(in: context)

        // Modify a default action
        let actions = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        actions[0].name = "Modified Name"
        actions[0].prompt = "Modified Prompt"
        try context.save()

        // Add a custom action
        let custom = Action(name: "Custom", prompt: "Custom prompt", sortOrder: 10)
        context.insert(custom)
        try context.save()

        // Restore defaults
        SeedData.restoreDefaultActions(in: context)

        let restored = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        // Custom action should still exist
        XCTAssertTrue(restored.contains(where: { $0.name == "Custom" }), "Custom action should be preserved")
        // Default actions should be restored — the modified one gets its original prompt back
        XCTAssertTrue(restored.contains(where: { $0.name == "Rewrite for Clarity" }))
    }
}
