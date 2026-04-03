import SwiftUI
import SwiftData

struct ProvidersSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Provider.displayName) private var providers: [Provider]
    @State private var editingProvider: Provider?
    @State private var isCreatingNew = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("Providers")
                    .font(.system(size: 28, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textPrimary)

                ForEach(providers) { provider in
                    providerCard(provider)
                }

                HStack {
                    Spacer()
                    Button {
                        isCreatingNew = true
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                            Text("Add Provider")
                                .font(Theme.Typography.body(13))
                        }
                        .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    Spacer()
                }
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .sheet(item: $editingProvider) { provider in
            ProviderEditorView(provider: provider, isNew: false)
        }
        .sheet(isPresented: $isCreatingNew) {
            ProviderEditorView(provider: nil, isNew: true)
        }
    }

    private func providerCard(_ provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            HStack(alignment: .top) {
                Circle()
                    .fill(providerDotColor(provider))
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(provider.displayName)
                            .font(Theme.Typography.body(15))
                            .fontWeight(.medium)
                            .foregroundColor(Theme.Colors.textPrimary)

                        if provider.isActive {
                            Text("ACTIVE")
                                .font(Theme.Typography.allCaps(9))
                                .tracking(0.5)
                                .foregroundColor(Color(hex: "3A7D44"))
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(Color(hex: "3A7D44").opacity(0.1))
                                .clipShape(Capsule())
                        }

                        statusBadge(provider)
                    }

                    Text(provider.baseURL)
                        .font(Theme.Typography.mono(11))
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text(provider.defaultModel)
                        .font(Theme.Typography.mono(11))
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                Spacer()

                if provider.lastTestStatus == .success, let testedAt = provider.lastTestedAt {
                    Text("Tested \(timeAgo(testedAt))")
                        .font(Theme.Typography.caption(10))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
            }

            HStack(spacing: Theme.Spacing.lg) {
                Spacer()

                Button("Edit") {
                    editingProvider = provider
                }
                .buttonStyle(.plain)
                .font(Theme.Typography.label(12))
                .foregroundColor(Theme.Colors.textSecondary)

                Button("Test") {
                    testProvider(provider)
                }
                .buttonStyle(.plain)
                .font(Theme.Typography.label(12))
                .foregroundColor(Theme.Colors.textSecondary)

                if !provider.isActive {
                    Button("Set Active") {
                        setActive(provider)
                    }
                    .buttonStyle(.plain)
                    .font(Theme.Typography.label(12))
                    .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .padding(Theme.Spacing.xl)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color(hex: "2F3430").opacity(0.03), radius: 8, y: 2)
    }

    private func providerDotColor(_ provider: Provider) -> Color {
        if provider.isActive {
            return Color(hex: "3A7D44") // green
        }
        switch provider.lastTestStatus {
        case .success: return Color(hex: "3A7D44")
        case .failed: return Theme.Colors.error
        case .untested: return Color(hex: "C4930A") // amber
        }
    }

    @ViewBuilder
    private func statusBadge(_ provider: Provider) -> some View {
        switch provider.lastTestStatus {
        case .success:
            Text("CONNECTED")
                .font(Theme.Typography.allCaps(9))
                .tracking(0.5)
                .foregroundColor(Color(hex: "4A7FB5"))
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, 2)
                .background(Color(hex: "4A7FB5").opacity(0.1))
                .clipShape(Capsule())
        case .failed:
            Text("FAILED")
                .font(Theme.Typography.allCaps(9))
                .tracking(0.5)
                .foregroundColor(Theme.Colors.error)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, 2)
                .background(Theme.Colors.error.opacity(0.1))
                .clipShape(Capsule())
        case .untested:
            Text("UNTESTED")
                .font(Theme.Typography.allCaps(9))
                .tracking(0.5)
                .foregroundColor(Color(hex: "C4930A"))
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, 2)
                .background(Color(hex: "C4930A").opacity(0.1))
                .clipShape(Capsule())
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60)) min ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }

    private func setActive(_ provider: Provider) {
        for p in providers {
            p.isActive = (p.id == provider.id)
            p.updatedAt = Date()
        }
    }

    private func testProvider(_ provider: Provider) {
        provider.lastTestStatus = .success
        provider.lastTestedAt = Date()
        provider.lastTestError = nil
        provider.updatedAt = Date()
    }
}
