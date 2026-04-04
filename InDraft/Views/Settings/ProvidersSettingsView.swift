import SwiftUI
import SwiftData

struct ProvidersSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Provider.displayName) private var providers: [Provider]
    @State private var expandedProviderID: UUID?

    // Inline new provider state
    @State private var isCreatingNew = false
    @State private var newDisplayName = ""
    @State private var newBaseURL = ""
    @State private var newAPIKey = ""
    @State private var newShowAPIKey = false
    @State private var newDefaultModel = ""
    @State private var newTimeoutSeconds: Double = 60

    private let keychainService = LiveKeychainService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                headerRow

                providersList

                if isCreatingNew {
                    newProviderForm
                }

                bottomBar
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Providers")
                .font(Theme.Typography.pageTitle())
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            Text("\(providers.count) configured")
                .font(Theme.Typography.caption(11))
                .foregroundColor(Theme.Colors.textTertiary)
        }
    }

    // MARK: - Providers List

    private var providersList: some View {
        VStack(spacing: 0) {
            ForEach(Array(providers.enumerated()), id: \.element.id) { index, provider in
                if index > 0 {
                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.lg)
                }
                providerRow(provider)
            }
        }
        .cardStyle()
    }

    // The canonical active provider — only one, by UUID
    private var activeProviderID: UUID? {
        providers.first { $0.isActive }?.id
    }

    // MARK: - Provider Row

    private func providerRow(_ provider: Provider) -> some View {
        let isExpanded = expandedProviderID == provider.id
        let isActiveProvider = provider.id == activeProviderID

        return VStack(alignment: .leading, spacing: 0) {
            // Collapsed header
            Button {
                withAnimation(Theme.Motion.standard) {
                    expandedProviderID = isExpanded ? nil : provider.id
                }
            } label: {
                HStack(spacing: 0) {
                    // Active indicator — subtle left accent bar
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isActiveProvider ? Theme.Colors.statusGreen : Color.clear)
                        .frame(width: 2)
                        .padding(.vertical, Theme.Spacing.sm)

                    HStack(spacing: Theme.Spacing.md) {
                        Circle()
                            .fill(providerDotColor(provider))
                            .frame(width: 6, height: 6)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Text(provider.displayName)
                                    .font(Theme.Typography.body(14))
                                    .fontWeight(isActiveProvider ? .semibold : .medium)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                if isActiveProvider {
                                    Text("active")
                                        .font(Theme.Typography.allCaps(9))
                                        .foregroundColor(Theme.Colors.statusGreenText)
                                        .tracking(0.5)
                                }
                            }

                            HStack(spacing: Theme.Spacing.sm) {
                                Text(provider.defaultModel)
                                    .font(Theme.Typography.mono(10))
                                    .foregroundColor(Theme.Colors.textTertiary)

                                statusText(provider)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.Colors.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.lg)
                }
                .padding(.leading, Theme.Spacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded inline editor
            if isExpanded {
                ProviderInlineEditor(
                    provider: provider,
                    isActiveProvider: isActiveProvider,
                    keychainService: keychainService,
                    onSetActive: { setActive(provider) },
                    onTest: {},
                    onDelete: {
                        withAnimation(Theme.Motion.standard) {
                            expandedProviderID = nil
                            deleteProvider(provider)
                        }
                    }
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - New Provider Form

    private var newProviderForm: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            HStack {
                Text("New Provider")
                    .font(Theme.Typography.body(14))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                Button {
                    withAnimation(Theme.Motion.standard) {
                        resetNewProvider()
                    }
                } label: {
                    Text("Cancel")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            fieldSection("DISPLAY NAME") {
                TextField("e.g. OpenAI", text: $newDisplayName)
                    .inputFieldStyle()
            }

            fieldSection("BASE URL") {
                TextField("https://api.openai.com/v1", text: $newBaseURL)
                    .inputFieldStyle()
            }

            fieldSection("API KEY") {
                HStack(spacing: Theme.Spacing.sm) {
                    Group {
                        if newShowAPIKey {
                            TextField("sk-...", text: $newAPIKey)
                        } else {
                            SecureField("sk-...", text: $newAPIKey)
                        }
                    }
                    .textFieldStyle(.plain)
                    .font(Theme.Typography.mono(13))
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))

                    Button {
                        newShowAPIKey.toggle()
                    } label: {
                        Image(systemName: newShowAPIKey ? "eye.slash" : "eye")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }

            fieldSection("MODEL") {
                TextField("e.g. gpt-4o-mini", text: $newDefaultModel)
                    .inputFieldStyle()
            }

            fieldSection("TIMEOUT") {
                HStack(spacing: Theme.Spacing.md) {
                    Slider(value: $newTimeoutSeconds, in: 10...180, step: 5)
                        .tint(Theme.Colors.textTertiary)

                    Text("\(Int(newTimeoutSeconds))s")
                        .font(Theme.Typography.mono(12))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }

            HStack {
                Spacer()
                Button {
                    createProvider()
                } label: {
                    Text("Add Provider")
                        .font(Theme.Typography.label(12))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .underline()
                }
                .buttonStyle(.plain)
                .disabled(newDisplayName.trimmingCharacters(in: .whitespaces).isEmpty || newBaseURL.isEmpty)
                .opacity(newDisplayName.trimmingCharacters(in: .whitespaces).isEmpty || newBaseURL.isEmpty ? 0.4 : 1.0)
            }
        }
        .padding(Theme.Spacing.xl)
        .cardStyle()
        .transition(.opacity)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button {
                withAnimation(Theme.Motion.standard) {
                    expandedProviderID = nil
                    isCreatingNew = true
                }
            } label: {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                    Text("Add Provider")
                        .font(Theme.Typography.label(12))
                }
                .foregroundColor(Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(isCreatingNew)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func fieldSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.allCaps(9))
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(1)
            content()
        }
    }

    private func providerDotColor(_ provider: Provider) -> Color {
        if provider.isActive {
            return Theme.Colors.statusGreen
        }
        switch provider.lastTestStatus {
        case .success: return Theme.Colors.statusGreen
        case .failed: return Theme.Colors.error
        case .untested: return Theme.Colors.statusAmber
        }
    }

    @ViewBuilder
    private func statusText(_ provider: Provider) -> some View {
        switch provider.lastTestStatus {
        case .success:
            if let testedAt = provider.lastTestedAt {
                Text("tested \(timeAgo(testedAt))")
                    .font(Theme.Typography.caption(10))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        case .failed:
            Text("connection failed")
                .font(Theme.Typography.caption(10))
                .foregroundColor(Theme.Colors.error)
        case .untested:
            Text("untested")
                .font(Theme.Typography.caption(10))
                .foregroundColor(Theme.Colors.statusAmberText)
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

    private func deleteProvider(_ provider: Provider) {
        if !provider.apiKeyReference.isEmpty {
            try? keychainService.delete(forReference: provider.apiKeyReference)
        }
        modelContext.delete(provider)
    }

    private func createProvider() {
        let trimmedName = newDisplayName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let reference = "provider-\(UUID().uuidString)"
        let provider = Provider(
            displayName: trimmedName,
            baseURL: newBaseURL,
            apiKeyReference: reference,
            defaultModel: newDefaultModel,
            timeoutSeconds: Int(newTimeoutSeconds)
        )
        modelContext.insert(provider)

        if !newAPIKey.isEmpty {
            try? keychainService.store(apiKey: newAPIKey, forReference: reference)
        }

        withAnimation(Theme.Motion.standard) {
            resetNewProvider()
        }
    }

    private func resetNewProvider() {
        isCreatingNew = false
        newDisplayName = ""
        newBaseURL = ""
        newAPIKey = ""
        newShowAPIKey = false
        newDefaultModel = ""
        newTimeoutSeconds = 60
    }
}

// MARK: - Provider Inline Editor

struct ProviderInlineEditor: View {
    @Bindable var provider: Provider
    var isActiveProvider: Bool
    let keychainService: LiveKeychainService
    let onSetActive: () -> Void
    let onTest: () -> Void
    let onDelete: () -> Void

    @State private var apiKey: String = ""
    @State private var showAPIKey = false
    @State private var isTesting = false
    @State private var testResultMessage: String?
    @State private var testSucceeded: Bool?
    @State private var confirmingDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(height: 1)

            // Display name
            fieldSection("DISPLAY NAME") {
                TextField("Provider name", text: $provider.displayName)
                    .inputFieldStyle()
                    .onChange(of: provider.displayName) { _, _ in
                        provider.updatedAt = Date()
                    }
            }

            // Base URL
            fieldSection("BASE URL") {
                TextField("https://api.openai.com/v1", text: $provider.baseURL)
                    .inputFieldStyle()
                    .onChange(of: provider.baseURL) { _, _ in
                        provider.updatedAt = Date()
                    }
            }

            // API Key
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
                    .background(Theme.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                    .onChange(of: apiKey) { _, newValue in
                        saveAPIKey(newValue)
                    }

                    Button {
                        showAPIKey.toggle()
                    } label: {
                        Image(systemName: showAPIKey ? "eye.slash" : "eye")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Default model
            fieldSection("MODEL") {
                TextField("e.g. gpt-4o-mini", text: $provider.defaultModel)
                    .inputFieldStyle()
                    .onChange(of: provider.defaultModel) { _, _ in
                        provider.updatedAt = Date()
                    }
            }

            // Timeout
            fieldSection("TIMEOUT") {
                HStack(spacing: Theme.Spacing.md) {
                    Slider(
                        value: Binding(
                            get: { Double(provider.timeoutSeconds) },
                            set: {
                                provider.timeoutSeconds = Int($0)
                                provider.updatedAt = Date()
                            }
                        ),
                        in: 10...180,
                        step: 5
                    )
                    .tint(Theme.Colors.textTertiary)

                    Text("\(provider.timeoutSeconds)s")
                        .font(Theme.Typography.mono(12))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }

            // Action buttons
            HStack {
                if !isActiveProvider {
                    Button {
                        onSetActive()
                    } label: {
                        Text("Set Active")
                            .font(Theme.Typography.label(11))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .underline()
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    runTest()
                } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        if isTesting {
                            ProgressView()
                                .controlSize(.mini)
                        }
                        Text("Test Connection")
                            .font(Theme.Typography.label(11))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .underline()
                    }
                }
                .buttonStyle(.plain)
                .disabled(isTesting || apiKey.isEmpty)
                .opacity(isTesting || apiKey.isEmpty ? 0.4 : 1.0)

                if let succeeded = testSucceeded, let message = testResultMessage {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: succeeded ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 11))
                        Text(message)
                            .font(Theme.Typography.caption(11))
                            .lineLimit(1)
                    }
                    .foregroundColor(succeeded ? Theme.Colors.statusGreen : Theme.Colors.error)
                }

                Spacer()

                Button {
                    if confirmingDelete {
                        confirmingDelete = false
                        onDelete()
                    } else {
                        withAnimation(Theme.Motion.quick) { confirmingDelete = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(Theme.Motion.quick) { confirmingDelete = false }
                        }
                    }
                } label: {
                    Text(confirmingDelete ? "Confirm delete?" : "Delete")
                        .font(Theme.Typography.label(11))
                        .foregroundColor(Theme.Colors.error)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.bottom, Theme.Spacing.lg)
        .onAppear {
            loadAPIKey()
        }
    }

    // MARK: - Helpers

    private func fieldSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.allCaps(9))
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(1)
            content()
        }
    }

    private func loadAPIKey() {
        if !provider.apiKeyReference.isEmpty {
            apiKey = keychainService.retrieve(forReference: provider.apiKeyReference) ?? ""
        }
    }

    private func saveAPIKey(_ newValue: String) {
        guard !newValue.isEmpty else { return }
        if provider.apiKeyReference.isEmpty {
            let reference = "provider-\(UUID().uuidString)"
            try? keychainService.store(apiKey: newValue, forReference: reference)
            provider.apiKeyReference = reference
        } else {
            do {
                try keychainService.update(apiKey: newValue, forReference: provider.apiKeyReference)
            } catch KeychainError.itemNotFound {
                try? keychainService.store(apiKey: newValue, forReference: provider.apiKeyReference)
            } catch {}
        }
        provider.updatedAt = Date()
    }

    private func runTest() {
        isTesting = true
        testResultMessage = nil
        testSucceeded = nil

        Task {
            let service = LiveProviderService()
            let result = await service.testConnection(
                baseURL: provider.baseURL,
                apiKey: apiKey,
                model: provider.defaultModel,
                timeout: TimeInterval(provider.timeoutSeconds)
            )

            await MainActor.run {
                isTesting = false
                switch result {
                case .success(_, let latencyMs):
                    testSucceeded = true
                    testResultMessage = "Connected — \(latencyMs)ms"
                    provider.lastTestStatus = .success
                    provider.lastTestedAt = Date()
                    provider.lastTestError = nil
                case .failure(let message):
                    testSucceeded = false
                    testResultMessage = message
                    provider.lastTestStatus = .failed
                    provider.lastTestError = message
                }
                provider.updatedAt = Date()
            }
        }
    }
}
