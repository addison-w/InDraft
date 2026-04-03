import SwiftUI

struct MenuBarIconView: View {
    let state: AppStatus

    @State private var rotationAngle: Double = 0

    var body: some View {
        switch state {
        case .idle:
            Image(systemName: "pencil.line")
        case .processing:
            Image(systemName: "arrow.trianglehead.2.counterclockwise")
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.0)
                        .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                }
                .onDisappear {
                    rotationAngle = 0
                }
        case .success:
            Image(systemName: "checkmark")
        case .error:
            Image(systemName: "exclamationmark.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.red)
        case .permissionRequired:
            Image(systemName: "exclamationmark.triangle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow)
        }
    }
}
