import SwiftUI
import SwiftData

struct HistoryWindowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HistoryRecord.timestamp, order: .reverse) private var records: [HistoryRecord]

    @State private var searchText = ""
    @State private var expandedRecordID: UUID?
    @State private var showClearConfirmation = false

    private let retentionDays = 30

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
            // Top bar: search + retention badge + clear all
            HStack(spacing: Theme.Spacing.md) {
                // Search field
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
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

                // Retention badge — pale blue pill
                Text("\(retentionDays) days")
                    .font(Theme.Typography.caption())
                    .foregroundColor(Theme.Colors.accent)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.accentContainer.opacity(0.5))
                    .clipShape(Capsule())

                // Clear all — plain text link in red
                Button {
                    showClearConfirmation = true
                } label: {
                    Text("Clear All")
                        .font(Theme.Typography.caption())
                        .foregroundColor(Theme.Colors.error)
                }
                .buttonStyle(.plain)
                .alert("Clear All History", isPresented: $showClearConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear All", role: .destructive) {
                        let service = LiveHistoryService(modelContext: modelContext)
                        service.clearAll()
                    }
                } message: {
                    Text("This will permanently delete all transformation history. This action cannot be undone.")
                }

                // Filter button
                Button {
                    // Filter menu placeholder
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)

            // Record list
            if filteredRecords.isEmpty {
                Spacer()
                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 28))
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
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if expandedRecordID == record.id {
                                            expandedRecordID = nil
                                        } else {
                                            expandedRecordID = record.id
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }

            // Footer — minimal muted text
            HStack {
                Text("\(filteredRecords.count) transformation\(filteredRecords.count == 1 ? "" : "s")")
                    .font(Theme.Typography.mono(10))
                    .foregroundColor(Theme.Colors.textTertiary)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
        }
        .frame(width: 650, height: 500)
        .background(Theme.Colors.background)
    }
}
