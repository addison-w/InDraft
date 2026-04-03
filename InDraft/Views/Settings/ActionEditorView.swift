import SwiftUI
import SwiftData

struct ActionEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Provider.displayName) private var providers: [Provider]

    let action: Action?
    let isNew: Bool

    @State private var name: String = ""
    @State private var prompt: String = ""
    @State private var hotkeyKeyCode: UInt32?
    @State private var hotkeyModifiers: UInt32?
    @State private var outputBehavior: OutputBehavior = .replace
    @State private var providerMode: ProviderMode = .active
    @State private var selectedProviderID: UUID?
    @State private var modelOverride: String = ""
    @State private var enabled: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            Text(isNew ? "New Action" : "Edit Action")
                .font(.system(size: 18, design: .serif))
                .fontWeight(.medium)
                .foregroundColor(Theme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)

            Divider()
                .foregroundColor(Theme.Colors.divider)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    fieldSection("NAME") {
                        TextField("Action name", text: $name)
                            .textFieldStyle(.plain)
                            .font(Theme.Typography.body(14))
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.surfaceContainerLow)
                            .cornerRadius(Theme.Radius.md)
                    }

                    fieldSection("PROMPT") {
                        TextEditor(text: $prompt)
                            .font(Theme.Typography.body(13))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80, maxHeight: 120)
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.surfaceContainerLow)
                            .cornerRadius(Theme.Radius.md)
                    }

                    fieldSection("HOTKEY") {
                        HotkeyRecorderView(
                            keyCode: $hotkeyKeyCode,
                            modifiers: $hotkeyModifiers
                        )
                    }

                    fieldSection("OUTPUT BEHAVIOR") {
                        Picker("", selection: $outputBehavior) {
                            ForEach(OutputBehavior.allCases, id: \.self) { behavior in
                                Text(behavior.rawValue.capitalized).tag(behavior)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    fieldSection("PROVIDER") {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Picker("", selection: $providerMode) {
                                Text("Use Active").tag(ProviderMode.active)
                                Text("Fixed Provider").tag(ProviderMode.fixed)
                            }
                            .pickerStyle(.segmented)

                            if providerMode == .fixed {
                                Picker("Provider", selection: $selectedProviderID) {
                                    Text("Select a provider...").tag(nil as UUID?)
                                    ForEach(providers) { provider in
                                        Text(provider.displayName).tag(provider.id as UUID?)
                                    }
                                }
                                .labelsHidden()
                            }

                            TextField("Model override (optional)", text: $modelOverride)
                                .textFieldStyle(.plain)
                                .font(Theme.Typography.body(13))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(Theme.Spacing.md)
                                .background(Theme.Colors.surfaceContainerLow)
                                .cornerRadius(Theme.Radius.md)
                        }
                    }

                    HStack {
                        Text("ENABLED")
                            .font(Theme.Typography.allCaps(10))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .tracking(1)
                        Spacer()
                        Toggle("", isOn: $enabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
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
                .font(Theme.Typography.body(13))
                .foregroundColor(Theme.Colors.textTertiary)

                Spacer()

                Button {
                    save()
                } label: {
                    Text("Save Action")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.vertical, Theme.Spacing.lg)
        }
        .frame(minWidth: 400, maxWidth: 400, minHeight: 520)
        .background(Theme.Colors.background)
        .onAppear {
            loadAction()
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

    private func loadAction() {
        guard let action else { return }
        name = action.name
        prompt = action.prompt
        hotkeyKeyCode = action.hotkeyKeyCode
        hotkeyModifiers = action.hotkeyModifiers
        outputBehavior = action.outputBehavior
        providerMode = action.providerMode
        selectedProviderID = action.providerID
        modelOverride = action.modelOverride ?? ""
        enabled = action.enabled
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let action {
            action.name = trimmedName
            action.prompt = prompt
            action.hotkeyKeyCode = hotkeyKeyCode
            action.hotkeyModifiers = hotkeyModifiers
            action.outputBehavior = outputBehavior
            action.providerMode = providerMode
            action.providerID = providerMode == .fixed ? selectedProviderID : nil
            action.modelOverride = modelOverride.isEmpty ? nil : modelOverride
            action.enabled = enabled
            action.updatedAt = Date()
        } else {
            let descriptor = FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
            let maxOrder = (try? modelContext.fetch(descriptor).first?.sortOrder) ?? -1
            let newAction = Action(
                name: trimmedName,
                prompt: prompt,
                hotkeyKeyCode: hotkeyKeyCode,
                hotkeyModifiers: hotkeyModifiers,
                outputBehavior: outputBehavior,
                providerMode: providerMode,
                providerID: providerMode == .fixed ? selectedProviderID : nil,
                modelOverride: modelOverride.isEmpty ? nil : modelOverride,
                enabled: enabled,
                sortOrder: maxOrder + 1
            )
            modelContext.insert(newAction)
        }

        dismiss()
    }
}
