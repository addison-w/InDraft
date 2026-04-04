import XCTest
@testable import InDraft

@MainActor
final class MenuBarAnimationTests: XCTestCase {

    func testRotatedSymbolReturnsImage() {
        let image = MenuBarController.rotatedSymbol(
            name: "arrow.trianglehead.2.counterclockwise",
            degrees: 0,
            accessibilityDescription: "Test"
        )
        XCTAssertNotNil(image)
    }

    func testRotatedSymbolIsTemplate() {
        let image = MenuBarController.rotatedSymbol(
            name: "arrow.trianglehead.2.counterclockwise",
            degrees: 120,
            accessibilityDescription: "Test"
        )
        XCTAssertTrue(image?.isTemplate ?? false)
    }

    func testRotatedSymbolDifferentAngles() {
        // Verify different angles produce non-nil images
        let angles: [CGFloat] = [0, 120, 240]
        for angle in angles {
            let image = MenuBarController.rotatedSymbol(
                name: "arrow.trianglehead.2.counterclockwise",
                degrees: angle,
                accessibilityDescription: "Test"
            )
            XCTAssertNotNil(image, "rotatedSymbol returned nil for angle \(angle)")
        }
    }

    func testRotatedSymbolInvalidNameReturnsNil() {
        let image = MenuBarController.rotatedSymbol(
            name: "nonexistent.symbol.name",
            degrees: 0,
            accessibilityDescription: "Test"
        )
        XCTAssertNil(image)
    }
}
