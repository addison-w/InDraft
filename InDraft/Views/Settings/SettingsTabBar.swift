import SwiftUI

/// A minimalist text-based tab bar for Settings navigation
struct SettingsTabBar: View {
    @Binding var selectedTab: SettingsTab

    @State private var hoveredTab: SettingsTab?

    var body: some View {
        HStack(spacing: 24) {
            ForEach(SettingsTab.allCases) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    isHovered: hoveredTab == tab,
                    action: { selectedTab = tab },
                    onHover: { isHovered in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            hoveredTab = isHovered ? tab : nil
                        }
                    }
                )
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.Colors.background)
    }
}

// MARK: - Tab Button

private struct TabButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    let onHover: (Bool) -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(tab.rawValue)
                    .font(.custom("Inter", size: 13).weight(.medium))
                    .foregroundColor(textColor)

                // Active indicator underline
                Rectangle()
                    .fill(isSelected ? Theme.Colors.accentContainer : Color.clear)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityHint("Double tap to select \(tab.rawValue) settings")
        .onHover(perform: onHover)
    }

    private var textColor: Color {
        if isSelected {
            return Theme.Colors.textPrimary
        } else if isHovered {
            return Theme.Colors.textSecondary
        } else {
            return Theme.Colors.textTertiary
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsTabBar(selectedTab: .constant(.general))
        .padding()
        .background(Color.gray.opacity(0.1))
}
