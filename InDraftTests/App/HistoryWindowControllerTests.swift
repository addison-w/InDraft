import XCTest
@testable import InDraft
import SwiftData

@MainActor
final class HistoryWindowControllerTests: XCTestCase {

    func testSingletonExists() {
        // HistoryWindowController should have a shared singleton
        let controller = HistoryWindowController.shared
        XCTAssertNotNil(controller, "HistoryWindowController.shared should exist")
    }

    func testSingletonIsSameInstance() {
        // Singleton should always return the same instance
        let controller1 = HistoryWindowController.shared
        let controller2 = HistoryWindowController.shared
        XCTAssertTrue(controller1 === controller2, "Singleton should return same instance")
    }

    func testConfigureMethodExists() {
        // HistoryWindowController should have a configure method
        let controller = HistoryWindowController.shared
        let appState = AppState()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let modelContainer = try? ModelContainer(for: schema, configurations: [config]) else {
            XCTFail("Failed to create model container")
            return
        }

        // Should not crash when calling configure
        controller.configure(appState: appState, modelContainer: modelContainer)
    }

    func testShowHistoryMethodExists() {
        // HistoryWindowController should have a showHistory method
        let controller = HistoryWindowController.shared

        // Configure first
        let appState = AppState()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let modelContainer = try? ModelContainer(for: schema, configurations: [config]) else {
            XCTFail("Failed to create model container")
            return
        }
        controller.configure(appState: appState, modelContainer: modelContainer)

        // Should not crash when calling showHistory
        controller.showHistory()
    }

    func testShowHistoryCanBeCalledMultipleTimes() {
        // Calling showHistory multiple times should not crash
        let controller = HistoryWindowController.shared

        let appState = AppState()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let modelContainer = try? ModelContainer(for: schema, configurations: [config]) else {
            XCTFail("Failed to create model container")
            return
        }
        controller.configure(appState: appState, modelContainer: modelContainer)

        // Call multiple times - should reuse window
        controller.showHistory()
        controller.showHistory()
        controller.showHistory()
    }
}