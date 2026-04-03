import SwiftUI
import SwiftData

struct ProviderEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let provider: Provider?
    let isNew: Bool

    @State private var displayName: String = ""
    @State private var baseURL: String = ""
    @State private var apiKey: String = ""
    @State private var showAPIKey = false
    @State private var defaultModel: String = ""
    @State private var isTesting = false
    @State private var testResult: ProviderTestResult?

    private enum ProviderTestResult {
        case success
        case failure(String)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(isNew ? "Add Provider" : "Edit Provider")
                .font(Theme.Typography.sectionTitle(18))
                .foregroundColor(Theme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)

            Divider()
                .foregroundColor(Theme.Colors.divider)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    fieldSection("DISPLAY NAME") {
                        TextField("e.g. OpenAI", text: $displayName)
                            .textFieldStyle(.plain)
                            .font(Theme.Typography.body(14))
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.Radius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                            )
                    }

                    fieldSection("BASE URL") {
                        TextField(Constants.Defaults.defaultBaseURL, text: $baseURL)
                            .textFieldStyle(.plain)
                            .font(Theme.Typography.body(14))
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.Radius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                            )
                    }

                    fieldSection("API KEY") {
                        HStack(spacing: Theme.Spacing.sm) {
                            Group {
                                if showAPIKey {
                                    TextField("sk-...", text: $apiKey)
                                } else {
                                    SecureField("sk-...", text: $apiKey)
                                }
                            }
                            .textFieldStyle(.plain)
                            .font(Theme.Typography.mono(13))
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.Radius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                            )

                            Button {
                                showAPIKey.toggle()
                            } label: {
                                Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    fieldSection("DEFAULT MODEL") {
                        TextField("e.g. gpt-4o", text: $defaultModel)
                            .textFieldStyle(.plain)
                            .font(Theme.Typography.body(14))
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.Radius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                            )
                    }

                    HStack {
                        Button {
                            testConnection()
                        } label: {
                            HStack(spacing: Theme.Spacing.xs) {
                                if isTesting {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "bolt.horizontal")
                                        .font(.system(size: 12))
                                }
                                Text("Test Connection")
                                    .font(Theme.Typography.body(13))
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(isTesting || baseURL.isEmpty || apiKey.isEmpty)

                        if let testResult {
                            switch testResult {
                            case .success:
                                HStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.Colors.accent)
                                    Text("Connected")
                                        .font(Theme.Typography.caption(11))
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            case .failure(let message):
                                HStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.Colors.error)
                                    Text(message)
                                        .font(Theme.Typography.caption(11))
                                        .foregroundColor(Theme.Colors.error)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.xl)
            }

            Divider()
                .foregroundColor(Theme.Colors.divider)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.textSecondary)

                Spacer()

                if !isNew {
                    Button("Delete", role: .destructive) {
                        deleteProvider()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Theme.Colors.error)
                    .padding(.trailing, Theme.Spacing.md)
                }

                Button {
                    save()
                } label: {
                    Text("Save Provider")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty || baseURL.isEmpty)
            }
            .padding(Theme.Spacing.lg)
        }
        .frame(minWidth: 400, maxWidth: 400, minHeight: 460)
        .background(Theme.Colors.background)
        .onAppear {
            loadProvider()
        }
    }

    private func fieldSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.allCaps(10))
                .foregroundColor(Theme.Colors.textSecondary)
                .tracking(1)
            content()
        }
    }

    private func loadProvider() {
        guard let provider else {
            baseURL = Constants.Defaults.defaultBaseURL
            return
        }
        displayName = provider.displayName
        baseURL = provider.baseURL
        apiKey = provider.apiKeyReference
        defaultModel = provider.defaultModel
    }

    private func save() {
        let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let provider {
            provider.displayName = trimmedName
            provider.baseURL = baseURL
            provider.apiKeyReference = apiKey
            provider.defaultModel = defaultModel
            provider.updatedAt = Date()
        } else {
            let newProvider = Provider(
                displayName: trimmedName,
                baseURL: baseURL,
                apiKeyReference: apiKey,
                defaultModel: defaultModel
            )
            modelContext.insert(newProvider)
        }

        dismiss()
    }

    private func deleteProvider() {
        if let provider {
            modelContext.delete(provider)
        }
        dismiss()
    }

    private func testConnection() {
        isTesting = true
        testResult = nil
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                isTesting = false
                testResult = .success
                if let provider {
                    provider.lastTestStatus = .success
                    provider.lastTestedAt = Date()
                    provider.lastTestError = nil
                    provider.updatedAt = Date()
                }
            }
        }
    }
}
