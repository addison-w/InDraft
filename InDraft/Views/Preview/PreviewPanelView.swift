import SwiftUI
import Hugeicons

struct PreviewPanelView: View {
    let originalText: String
    let transformedText: String
    var onAccept: () -> Void = {}
    var onReject: () -> Void = {}
    var onCopy: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Text("InDraft")
                    .font(Theme.Typography.sectionTitle(16))
                    .italic()
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()
            }
            .overlay(alignment: .trailing) {
                Menu {
                    Button("Copy Original") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(originalText, forType: .string)
                    }
                    Button("Copy Transformed") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(transformedText, forType: .string)
                    }
                } label: {
                    AppIcon.menu.image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: 24, height: 24)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)

            // Two-column text comparison
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                // Original column — warm bone background
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("ORIGINAL")
                        .font(Theme.Typography.allCaps())
                        .tracking(1.2)
                        .foregroundColor(Theme.Colors.textTertiary)

                    ScrollView {
                        Text(originalText)
                            .font(Theme.Typography.body())
                            .foregroundColor(Theme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.background)

                // Transformed column — white card
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("TRANSFORMED")
                        .font(Theme.Typography.allCaps())
                        .tracking(1.2)
                        .foregroundColor(Theme.Colors.textTertiary)

                    ScrollView {
                        Text(transformedText)
                            .font(Theme.Typography.body(13))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Bottom action buttons
            HStack(spacing: Theme.Spacing.md) {
                Spacer()

                // REJECT — outline button
                Button("REJECT") {
                    onReject()
                }
                .buttonStyle(.plain)
                .font(Theme.Typography.label(12))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )

                // COPY — outline button
                Button("COPY") {
                    onCopy()
                }
                .buttonStyle(.plain)
                .font(Theme.Typography.label(12))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )

                // ACCEPT — solid dark button
                Button("ACCEPT") {
                    onAccept()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
        }
        .frame(width: 450, height: 300)
        .background(Theme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
        )
        .shadow(color: Theme.Colors.textPrimary.opacity(0.06), radius: 16, y: 6)
    }
}
