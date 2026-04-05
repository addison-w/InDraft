import XCTest
@testable import InDraft

@MainActor
final class MenuBarAnimationTests: XCTestCase {

    func testBouncingBallFrameReturnsImage() {
        // The bouncing ball animation generates frames procedurally
        // Verify each frame in the cycle produces a valid template image
        for i in 0..<17 {
            let image = MenuBarController.bouncingBallFrame(index: i)
            XCTAssertTrue(image.isTemplate, "Frame \(i) should be a template image")
            XCTAssertEqual(image.size, NSSize(width: 18, height: 18), "Frame \(i) should be 18x18")
        }
    }
}
