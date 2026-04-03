import SwiftUI

struct HistoryRecordDetailView: View {
    let record: HistoryRecord

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Two-column text comparison
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                // Original column — warm bone background
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("ORIGINAL")
                        .font(Theme.Typography.allCaps())
                        .tracking(1.2)
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text(record.originalText)
                        .font(Theme.Typography.body())
                        .foregroundColor(Theme.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                }
                .frame(maxWidth: .infinity)

                // Transformed column — white card
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("TRANSFORMED")
                        .font(Theme.Typography.allCaps())
                        .tracking(1.2)
                        .foregroundColor(Theme.Colors.textTertiary)

                    if let transformed = record.transformedText {
                        Text(transformed)
                            .font(Theme.Typography.body())
                            .foregroundColor(Theme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                            .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                        )
                    } else if let errorMessage = record.errorMessage {
                        Text(errorMessage)
                            .font(Theme.Typography.body())
                            .foregroundColor(Theme.Colors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.error.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Action buttons — small text links
            HStack(spacing: Theme.Spacing.lg) {
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(record.originalText, forType: .string)
                } label: {
                    Text("Copy Original")
                        .font(Theme.Typography.caption())
                        .underline()
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.textSecondary)

                Button {
                    if let transformed = record.transformedText {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(transformed, forType: .string)
                    }
                } label: {
                    Text("Copy Result")
                        .font(Theme.Typography.caption())
                        .underline()
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.textSecondary)
                .disabled(record.transformedText == nil)

                Button {
                    // Retry action - placeholder for retry logic
                } label: {
                    Text("Retry")
                        .font(Theme.Typography.caption())
                        .underline()
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.textSecondary)

                Spacer()

                Button {
                    let service = LiveHistoryService(modelContext: modelContext)
                    service.deleteRecord(record.id)
                } label: {
                    Text("Delete")
                        .font(Theme.Typography.caption())
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.error.opacity(0.7))
            }
        }
    }
}
