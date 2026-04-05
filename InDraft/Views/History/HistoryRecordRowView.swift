import SwiftUI
import Hugeicons

struct HistoryRecordRowView: View {
    let record: HistoryRecord
    let isExpanded: Bool
    let onToggle: () -> Void
    var onDelete: (() -> Void)?

    private var formattedTimestamp: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let time = formatter.string(from: record.timestamp)

        if calendar.isDateInToday(record.timestamp) {
            return "TODAY \u{00B7} \(time)"
        } else if calendar.isDateInYesterday(record.timestamp) {
            return "YESTERDAY \u{00B7} \(time)"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "MMM d"
            return "\(dayFormatter.string(from: record.timestamp).uppercased()) \u{00B7} \(time)"
        }
    }

    private var formattedLatency: String {
        let seconds = Double(record.latencyMs) / 1000.0
        if seconds < 10 {
            return String(format: "%.1fs", seconds)
        } else {
            return String(format: "%.0fs", seconds)
        }
    }

    private var isDeleted: Bool {
        record.modelContext == nil
    }

    @ViewBuilder
    var body: some View {
        if !isDeleted {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: Theme.Spacing.sm) {
                    // Timestamp — monospaced secondary
                    Text(formattedTimestamp)
                        .font(Theme.Typography.mono(10))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text(record.sourceApp.uppercased())
                        .font(Theme.Typography.allCaps(9))
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.inverseSurface)
                        .clipShape(Capsule())

                    Text(record.actionName)
                        .font(Theme.Typography.sectionTitle(14))
                        .italic()
                        .foregroundColor(Theme.Colors.textPrimary)

                    Spacer()

                    // Latency — monospaced
                    Text(formattedLatency)
                        .font(Theme.Typography.mono(10))
                        .foregroundColor(Theme.Colors.textTertiary)

                    // Status badge
                    StatusPill(
                        text: record.status == .success ? "SUCCESS" : "ERROR",
                        color: record.status == .success ? Theme.Colors.statusGreenText : Theme.Colors.statusRed
                    )

                    // Expand chevron
                    (isExpanded ? AppIcon.chevronDown : AppIcon.chevronRight).image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                HistoryRecordDetailView(record: record, onDelete: onDelete)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

        }
        } // if !isDeleted
    }
}
