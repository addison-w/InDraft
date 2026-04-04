import SwiftUI

/// Wabi-sabi ink-line illustration: an abstract key motif with spare,
/// asymmetric strokes suggesting connection and access.
struct WabiSabiKeyIllustration: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let midY = size.height / 2

            // Key shaft — a gentle diagonal line
            var shaft = Path()
            shaft.move(to: CGPoint(x: midX - size.width * 0.18, y: midY + size.height * 0.22))
            shaft.addQuadCurve(
                to: CGPoint(x: midX + size.width * 0.16, y: midY - size.height * 0.18),
                control: CGPoint(x: midX - 2, y: midY - 1)
            )

            context.stroke(
                shaft,
                with: .color(Theme.Colors.textPrimary.opacity(0.78)),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )

            // Key bow (top circle) — open, imperfect arc
            let bowCenter = CGPoint(x: midX + size.width * 0.17, y: midY - size.height * 0.22)
            var bow = Path()
            bow.addArc(
                center: bowCenter,
                radius: size.width * 0.12,
                startAngle: .degrees(-30),
                endAngle: .degrees(290),
                clockwise: false
            )

            context.stroke(
                bow,
                with: .color(Theme.Colors.textPrimary.opacity(0.72)),
                style: StrokeStyle(lineWidth: 1.3, lineCap: .round)
            )

            // Key tooth — a small perpendicular tick near the shaft end
            var tooth = Path()
            tooth.move(to: CGPoint(x: midX - size.width * 0.08, y: midY + size.height * 0.12))
            tooth.addLine(to: CGPoint(x: midX - size.width * 0.08, y: midY + size.height * 0.2))

            context.stroke(
                tooth,
                with: .color(Theme.Colors.textPrimary.opacity(0.6)),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
        }
        .frame(width: 44, height: Theme.Illustrations.illustrationHeight)
    }
}
