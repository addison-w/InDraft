import SwiftUI

struct HistoryRecordRowView: View {
    let record: HistoryRecord
    let isExpanded: Bool
    let onToggle: () -> Void

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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: Theme.Spacing.sm) {
                    // Timestamp — monospaced secondary
                    Text(formattedTimestamp)
                        .font(Theme.Typography.mono(10))
                        .foregroundColor(Theme.Colors.textTertiary)

                    // Source app badge
                    Text(record.sourceApp.uppercased())
                        .font(Theme.Typography.caption(9))
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.textPrimary)
                        .clipShape(Capsule())

                    // Action name — italic serif
                    Text(record.actionName)
                        .font(.system(size: 14, design: .serif))
                        .italic()
                        .foregroundColor(Theme.Colors.textPrimary)

                    Spacer()

                    // Latency — monospaced
                    Text(formattedLatency)
                        .font(Theme.Typography.mono(10))
                        .foregroundColor(Theme.Colors.textTertiary)

                    // Status badge — pale green/red pill
                    Text(record.status == .success ? "SUCCESS" : "ERROR")
                        .font(Theme.Typography.caption(9))
                        .fontWeight(.medium)
                        .foregroundColor(
                            record.status == .success
                                ? Color(hex: "346538")
                                : Color(hex: "9F2F2D")
                        )
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            record.status == .success
                                ? Color(hex: "EDF3EC")
                                : Color(hex: "FDEBEC")
                        )
                        .clipShape(Capsule())

                    // Expand chevron
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                HistoryRecordDetailView(record: record)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

        }
    }
}
