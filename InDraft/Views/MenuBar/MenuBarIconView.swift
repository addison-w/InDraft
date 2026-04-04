import SwiftUI
import Hugeicons

private struct BouncingBallIcon: View {
    @State private var phase: CGFloat = 0
    @State private var squish: Bool = false

    var body: some View {
        Canvas { context, size in
            let ballRadius: CGFloat = 3.5
            let topY: CGFloat = size.height * 0.2
            let bottomY: CGFloat = size.height * 0.8
            let cy = topY + (bottomY - topY) * phase
            let rx = squish ? ballRadius * 1.2 : ballRadius
            let ry = squish ? ballRadius * 0.75 : ballRadius
            let rect = CGRect(
                x: size.width / 2 - rx,
                y: cy - ry,
                width: rx * 2,
                height: ry * 2
            )
            context.fill(Ellipse().path(in: rect), with: .foreground)
        }
        .frame(width: 16, height: 16)
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        func cycle() {
            phase = 0
            squish = false
            withAnimation(.timingCurve(0.33, 0, 0.66, 0.33, duration: 0.375)) {
                phase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.375) {
                squish = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    squish = false
                    withAnimation(.timingCurve(0.33, 0.66, 0.66, 1, duration: 0.4)) {
                        phase = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        cycle()
                    }
                }
            }
        }
        cycle()
    }
}

struct MenuBarIconView: View {
    let state: AppStatus

    var body: some View {
        switch state {
        case .idle:
            AppIcon.edit.image()
        case .processing:
            BouncingBallIcon()
        case .success:
            AppIcon.success.image()
        case .error:
            AppIcon.error.image()
                .foregroundStyle(.red)
        case .permissionRequired:
            AppIcon.warning.image()
                .foregroundStyle(.yellow)
        }
    }
}
