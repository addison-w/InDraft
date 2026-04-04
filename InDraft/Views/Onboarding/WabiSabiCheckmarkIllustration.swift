import SwiftUI

/// Wabi-sabi ink-line illustration: a simple checkmark motif with
/// spare brush-like strokes and deliberate asymmetry.
struct WabiSabiCheckmarkIllustration: View {
    var body: some View {
        Canvas { context, size in
            let startX = size.width * 0.22
            let midX = size.width * 0.42
            let endX = size.width * 0.78

            let bottomY = size.height * 0.68
            let startY = size.height * 0.48
            let topY = size.height * 0.25

            // Short descending stroke (left side of check)
            var leftStroke = Path()
            leftStroke.move(to: CGPoint(x: startX, y: startY))
            leftStroke.addQuadCurve(
                to: CGPoint(x: midX + 1, y: bottomY),
                control: CGPoint(x: startX + 6, y: bottomY - 4)
            )

            context.stroke(
                leftStroke,
                with: .color(Theme.Colors.textPrimary.opacity(0.8)),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )

            // Long ascending stroke (right side of check) — thinner for asymmetry
            var rightStroke = Path()
            rightStroke.move(to: CGPoint(x: midX - 0.5, y: bottomY + 1))
            rightStroke.addQuadCurve(
                to: CGPoint(x: endX, y: topY),
                control: CGPoint(x: endX - 8, y: bottomY - 14)
            )

            context.stroke(
                rightStroke,
                with: .color(Theme.Colors.textPrimary.opacity(0.72)),
                style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
            )
        }
        .frame(width: 48, height: 48)
    }
}
