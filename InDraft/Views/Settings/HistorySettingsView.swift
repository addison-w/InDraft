import SwiftUI

struct HistorySettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.historyRetentionDays) private var retentionDays = Constants.Defaults.historyRetentionDays
    @AppStorage(Constants.UserDefaultsKeys.historyRecordingEnabled) private var recordingEnabled = true
    @State private var showClearConfirmation = false

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
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                    .padding(Theme.Spacing.xl)

                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Retention picker
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Retention Period")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Automatically delete entries older than this")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        Picker("", selection: $retentionDays) {
                            ForEach(retentionOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
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
                        Button("Clear All") {
                            showClearConfirmation = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(Theme.Spacing.xl)
                }
                .cardStyle()

                // Privacy note
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 11))
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
        .alert("Clear All History", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                clearAllHistory()
            }
        } message: {
            Text("This will permanently delete all history entries. This action cannot be undone.")
        }
    }

    private func clearAllHistory() {
        // Placeholder: real implementation would delete all HistoryEntry records from SwiftData
    }
}
