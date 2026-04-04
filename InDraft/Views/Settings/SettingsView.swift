import SwiftUI
import SwiftData

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case actions = "Actions"
    case providers = "Providers"
    case history = "History"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .actions: return "bolt.fill"
        case .providers: return "puzzlepiece.fill"
        case .history: return "clock"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: SettingsTab = .general
    @State private var hoveredTab: SettingsTab?

    var body: some View {
        HStack(spacing: 0) {
            sidebar

            // Vertical divider
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(width: 1)

            // Detail
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .frame(width: 760, height: 540)
        .background(Theme.Colors.background)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WindowCloseButton()
                Spacer()
            }
            .padding(.leading, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.sm)
            .background(WindowDragArea())

            VStack(alignment: .leading, spacing: 3) {
                Text("InDraft")
                    .font(Theme.Typography.brand(15))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .tracking(0.5)
                Text("PREFERENCES")
                    .font(Theme.Typography.allCaps(9))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(1)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.xl)

            VStack(spacing: 2) {
                ForEach(SettingsTab.allCases) { tab in
                    sidebarItem(tab)
                }
            }

            Spacer()
        }
        .frame(width: 200)
        .background(Theme.Colors.background)
    }

    private func sidebarItem(_ tab: SettingsTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: tab.icon)
                    .font(.system(size: 11))
                    .foregroundColor(selectedTab == tab ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                    .frame(width: 16)
                Text(tab.rawValue)
                    .font(Theme.Typography.body(13))
            }
            .foregroundColor(selectedTab == tab ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
            .fontWeight(selectedTab == tab ? .medium : .regular)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .fill(selectedTab == tab
                        ? Theme.Colors.surfaceContainerLow
                        : hoveredTab == tab
                            ? Theme.Colors.surfaceContainerLow.opacity(0.5)
                            : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            withAnimation(Theme.Motion.quick) {
                hoveredTab = isHovered ? tab : nil
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .general:
            GeneralSettingsView()
        case .actions:
            ActionsSettingsView()
        case .providers:
            ProvidersSettingsView()
        case .history:
            HistorySettingsView()
        }
    }
}
