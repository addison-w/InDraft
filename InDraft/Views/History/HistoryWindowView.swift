import SwiftUI
import SwiftData
import Hugeicons

struct HistoryWindowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HistoryRecord.timestamp, order: .reverse) private var records: [HistoryRecord]

    @AppStorage(Constants.UserDefaultsKeys.historyRetentionDays) private var retentionDays = Constants.Defaults.historyRetentionDays

    @State private var searchText = ""
    @State private var expandedRecordID: UUID?
    @State private var confirmingClearAll = false

    private var filteredRecords: [HistoryRecord] {
        if searchText.isEmpty {
            return records
        }
        let query = searchText.lowercased()
        return records.filter { record in
            record.actionName.lowercased().contains(query) ||
            record.sourceApp.lowercased().contains(query) ||
            record.originalText.lowercased().contains(query) ||
            (record.transformedText?.lowercased().contains(query) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom titlebar with traffic lights
            titleBar

            // Divider
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(height: 1)

            // Top bar: search + retention badge + clear all
            searchBar

            // Record list
            if filteredRecords.isEmpty {
                Spacer()
                VStack(spacing: Theme.Spacing.sm) {
                    AppIcon.clockRewind.image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Theme.Colors.textTertiary)
                    Text(searchText.isEmpty ? "No transformation history yet" : "No results found")
                        .font(Theme.Typography.body())
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.xs) {
                        ForEach(filteredRecords, id: \.id) { record in
                            HistoryRecordRowView(
                                record: record,
                                isExpanded: expandedRecordID == record.id,
                                onToggle: {
                                    withAnimation(Theme.Motion.standard) {
                                        expandedRecordID = expandedRecordID == record.id ? nil : record.id
                                    }
                                }
                            )
                        }
                    }
                }
            }

            // Footer
            HStack {
                Text("\(filteredRecords.count) transformation\(filteredRecords.count == 1 ? "" : "s")")
                    .font(Theme.Typography.mono(10))
                    .foregroundColor(Theme.Colors.textTertiary)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
        }
        .ignoresSafeArea()
        .frame(width: 700, height: 520)
        .background(Theme.Colors.background)
    }

    // MARK: - Title Bar

    private var titleBar: some View {
        HStack(spacing: Theme.Spacing.md) {
            WindowCloseButton()

            Text("History")
                .font(Theme.Typography.label(12))
                .foregroundColor(Theme.Colors.textTertiary)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.Colors.background)
        .background(WindowDragArea())
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Search field
            HStack(spacing: Theme.Spacing.sm) {
                AppIcon.search.image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Theme.Colors.textTertiary)
                TextField("Search history...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(Theme.Typography.body())
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Colors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))

            Spacer()

            StatusPill(text: retentionDays > 0 ? "\(retentionDays) days" : "Unlimited", color: Theme.Colors.accent)

            // Clear all — inline confirmation (matches delete action/provider pattern)
            Button {
                if confirmingClearAll {
                    confirmingClearAll = false
                    let service = LiveHistoryService(modelContext: modelContext)
                    service.clearAll()
                } else {
                    withAnimation(Theme.Motion.quick) { confirmingClearAll = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(Theme.Motion.quick) { confirmingClearAll = false }
                    }
                }
            } label: {
                Text(confirmingClearAll ? "Confirm clear?" : "Clear All")
                    .font(Theme.Typography.caption())
                    .foregroundColor(Theme.Colors.error)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
    }
}
