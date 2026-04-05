import SwiftUI
import Hugeicons

struct HistorySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(Constants.UserDefaultsKeys.historyRetentionDays) private var retentionDays = Constants.Defaults.historyRetentionDays
    @AppStorage(Constants.UserDefaultsKeys.historyRecordingEnabled) private var recordingEnabled = true
    @State private var confirmingClear = false
    @State private var cleared = false
    @State private var pendingRetention: Int?
    @State private var showRetentionAlert = false

    private let retentionOptions: [(label: String, value: Int)] = [
        ("7 days", 7),
        ("30 days", 30),
        ("90 days", 90),
        ("Unlimited", 0),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("History")
                    .font(Theme.Typography.pageTitle())
                    .foregroundColor(Theme.Colors.textPrimary)

                VStack(alignment: .leading, spacing: 0) {
                    // Recording toggle
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Record History")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Save a log of all text transformations")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        Toggle("", isOn: $recordingEnabled)
                            .toggleStyle(WabiSabiToggleStyle())
                            .labelsHidden()
                    }
                    .padding(Theme.Spacing.xl)

                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Retention picker
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Retention Period")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Automatically delete entries older than this")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }

                        InkSegmentPicker(
                            options: retentionOptions,
                            selection: Binding(
                                get: { retentionDays },
                                set: { newValue in
                                    // If reducing retention (newValue > 0 and less than current, or current is unlimited)
                                    if newValue > 0 && (retentionDays == 0 || newValue < retentionDays) {
                                        pendingRetention = newValue
                                        showRetentionAlert = true
                                    } else {
                                        retentionDays = newValue
                                    }
                                }
                            )
                        )
                    }
                    .padding(Theme.Spacing.xl)

                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Clear all
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Clear All History")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Permanently delete all saved history entries")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        if cleared {
                            Text("Cleared")
                                .font(Theme.Typography.label(11))
                                .foregroundColor(Theme.Colors.statusGreen)
                                .transition(.opacity)
                        } else {
                            Button {
                                if confirmingClear {
                                    confirmingClear = false
                                    clearAllHistory()
                                    withAnimation(Theme.Motion.quick) { cleared = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation(Theme.Motion.quick) { cleared = false }
                                    }
                                } else {
                                    withAnimation(Theme.Motion.quick) { confirmingClear = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(Theme.Motion.quick) { confirmingClear = false }
                                    }
                                }
                            } label: {
                                HStack(spacing: Theme.Spacing.xs) {
                                    AppIcon.close.image()
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 11, height: 11)
                                    Text(confirmingClear ? "Confirm clear?" : "Clear All")
                                        .font(Theme.Typography.label(11))
                                }
                                .foregroundColor(Theme.Colors.error)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Theme.Spacing.xl)
                }
                .cardStyle()

                // Privacy note
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    AppIcon.shieldKey.image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                        .foregroundColor(Theme.Colors.textTertiary.opacity(0.7))
                        .padding(.top, 2)
                    Text("History data is stored locally on your Mac and is never sent to any server. Clearing history is permanent and cannot be undone.")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.textTertiary.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
                .padding(.horizontal, Theme.Spacing.sm)

                Spacer()
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .alert("Reduce retention period?", isPresented: $showRetentionAlert) {
            Button("Delete Old Data", role: .destructive) {
                if let newDays = pendingRetention {
                    retentionDays = newDays
                    let service = LiveHistoryService(modelContext: modelContext)
                    service.pruneOldRecords(retentionDays: newDays)
                }
                pendingRetention = nil
            }
            Button("Cancel", role: .cancel) {
                pendingRetention = nil
            }
        } message: {
            if let days = pendingRetention {
                Text("This will permanently delete all history entries older than \(days) days. This cannot be undone.")
            }
        }
    }

    private func clearAllHistory() {
        let service = LiveHistoryService(modelContext: modelContext)
        service.clearAll()
    }
}
