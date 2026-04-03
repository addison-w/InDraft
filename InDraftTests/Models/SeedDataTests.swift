import XCTest
import SwiftData
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

    func testCreateDefaultActionsSeeds3Actions() throws {
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        XCTAssertEqual(actions.count, 3)
        XCTAssertEqual(actions[0].name, "Rewrite for Clarity")
        XCTAssertEqual(actions[1].name, "Grammar Fix")
        XCTAssertEqual(actions[2].name, "Paraphrase")
    }

    func testCreateDefaultActionsIdempotent() throws {
        SeedData.createDefaultActions(in: context)
        SeedData.createDefaultActions(in: context)

        let actions = try context.fetch(FetchDescriptor<Action>())
        XCTAssertEqual(actions.count, 3, "Should not duplicate actions on second call")
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
