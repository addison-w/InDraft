import SwiftUI
import SwiftData

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case actions = "Actions"
    case providers = "Providers"
    case history = "History"
    case diagnostics = "Diagnostics"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .actions: return "bolt.fill"
        case .providers: return "puzzlepiece.fill"
        case .history: return "clock"
        case .diagnostics: return "stethoscope"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .frame(width: 700, height: 500)
        .background(Theme.Colors.background)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("InDraft")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text("PREFERENCES")
                    .font(Theme.Typography.allCaps(9))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(1)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)

            ForEach(SettingsTab.allCases) { tab in
                sidebarItem(tab)
            }

            Spacer()
        }
        .frame(minWidth: 140, maxWidth: 160)
        .background(Theme.Colors.background)
    }

    @State private var hoveredTab: SettingsTab?

    private func sidebarItem(_ tab: SettingsTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(tab.rawValue)
                    .font(Theme.Typography.body())
            }
            .foregroundColor(selectedTab == tab ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
            .fontWeight(selectedTab == tab ? .medium : .regular)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .fill(selectedTab == tab
                        ? Theme.Colors.surfaceContainerLow
                        : hoveredTab == tab
                            ? Theme.Colors.surfaceContainerLow.opacity(0.5)
                            : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            hoveredTab = isHovered ? tab : nil
        }
        .padding(.horizontal, Theme.Spacing.sm)
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
        case .diagnostics:
            DiagnosticsSettingsView()
        }
    }
}
