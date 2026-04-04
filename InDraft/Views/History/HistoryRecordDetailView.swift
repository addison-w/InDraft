import SwiftUI
import Hugeicons

struct HistoryRecordDetailView: View {
    let record: HistoryRecord

    @Environment(\.modelContext) private var modelContext
    @State private var copiedOriginal = false
    @State private var copiedTransformed = false
    @State private var confirmingDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Two-column text comparison
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                // Original column — warm bone background
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Text("ORIGINAL")
                            .font(Theme.Typography.allCaps())
                            .tracking(1.2)
                            .foregroundColor(Theme.Colors.textTertiary)
                        Spacer()
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(record.originalText, forType: .string)
                            withAnimation(Theme.Motion.quick) { copiedOriginal = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(Theme.Motion.quick) { copiedOriginal = false }
                            }
                        } label: {
                            (copiedOriginal ? AppIcon.success : AppIcon.copy).image()
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(copiedOriginal ? Theme.Colors.statusGreen : Theme.Colors.textTertiary)
                        }
                        .buttonStyle(.plain)
                    }

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
                    HStack {
                        Text("TRANSFORMED")
                            .font(Theme.Typography.allCaps())
                            .tracking(1.2)
                            .foregroundColor(Theme.Colors.textTertiary)
                        Spacer()
                        if record.transformedText != nil {
                            Button {
                                if let transformed = record.transformedText {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(transformed, forType: .string)
                                    withAnimation(Theme.Motion.quick) { copiedTransformed = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation(Theme.Motion.quick) { copiedTransformed = false }
                                    }
                                }
                            } label: {
                                (copiedTransformed ? AppIcon.success : AppIcon.copy).image()
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(copiedTransformed ? Theme.Colors.statusGreen : Theme.Colors.textTertiary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

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

            // Delete button — inline confirmation
            HStack {
                Spacer()

                Button {
                    if confirmingDelete {
                        confirmingDelete = false
                        let service = LiveHistoryService(modelContext: modelContext)
                        service.deleteRecord(record.id)
                    } else {
                        withAnimation(Theme.Motion.quick) { confirmingDelete = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(Theme.Motion.quick) { confirmingDelete = false }
                        }
                    }
                } label: {
                    Text(confirmingDelete ? "Confirm delete?" : "Delete")
                        .font(Theme.Typography.caption())
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.error.opacity(0.7))
            }
        }
    }
}
