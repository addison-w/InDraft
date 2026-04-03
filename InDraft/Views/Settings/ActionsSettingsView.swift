import SwiftUI
import SwiftData

struct ActionsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @State private var expandedActionID: UUID?
    @State private var isReordering = false
    @State private var showRestoreConfirmation = false

    // Inline new action state
    @State private var isCreatingNew = false
    @State private var newName = ""
    @State private var newPrompt = ""
    @State private var newHotkeyKeyCode: UInt32?
    @State private var newHotkeyModifiers: UInt32?
    @State private var newOutputBehavior: OutputBehavior = .replace
    @State private var newProviderMode: ProviderMode = .active
    @State private var newProviderID: UUID?
    @State private var newModelOverride = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                headerRow

                actionsList

                if isCreatingNew {
                    newActionForm
                }

                bottomBar
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .alert("Restore Defaults", isPresented: $showRestoreConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Restore", role: .destructive) {
                restoreDefaults()
            }
        } message: {
            Text("This will remove all custom actions and restore the default set. This cannot be undone.")
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Actions")
                .font(Theme.Typography.pageTitle())
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            if !actions.isEmpty {
                Button {
                    withAnimation(Theme.Motion.standard) {
                        isReordering.toggle()
                        expandedActionID = nil
                    }
                } label: {
                    Text(isReordering ? "DONE" : "REORDER")
                        .font(Theme.Typography.allCaps(10))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .tracking(0.5)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions List

    private var actionsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                if index > 0 {
                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.lg)
                }
                actionRow(action, index: index)
            }
        }
        .cardStyle()
    }

    // MARK: - Collapsed Row

    private func actionRow(_ action: Action, index: Int) -> some View {
        let isExpanded = expandedActionID == action.id && !isReordering

        return VStack(alignment: .leading, spacing: 0) {
            // Header row — always visible
            Button {
                withAnimation(Theme.Motion.standard) {
                    if isReordering { return }
                    expandedActionID = isExpanded ? nil : action.id
                }
            } label: {
                HStack(spacing: Theme.Spacing.md) {
                    if isReordering {
                        reorderControls(action, index: index)
                    }

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(action.name)
                            .font(Theme.Typography.body(14))
                            .fontWeight(.medium)
                            .foregroundColor(Theme.Colors.textPrimary)

                        HStack(spacing: Theme.Spacing.sm) {
                            if action.hasHotkey {
                                Text(action.hotkeyDisplayString)
                                    .font(Theme.Typography.mono(10))
                                    .foregroundColor(Theme.Colors.textTertiary)
                            }

                            Text(action.outputBehavior.rawValue.uppercased())
                                .font(Theme.Typography.allCaps(9))
                                .foregroundColor(Theme.Colors.textTertiary)
                                .tracking(0.5)
                        }
                    }

                    Spacer()

                    if !isReordering {
                        Toggle("", isOn: Binding(
                            get: { action.enabled },
                            set: { newValue in
                                action.enabled = newValue
                                action.updatedAt = Date()
                                appCoordinator.refreshHotkeys()
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .controlSize(.small)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.Colors.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded inline editor
            if isExpanded {
                ActionInlineEditor(action: action, onDelete: {
                    withAnimation(Theme.Motion.standard) {
                        expandedActionID = nil
                        deleteAction(action)
                    }
                }, onDuplicate: {
                    duplicateAction(action)
                })
                .transition(.opacity)
            }
        }
    }

    // MARK: - Reorder Controls

    private func reorderControls(_ action: Action, index: Int) -> some View {
        VStack(spacing: 2) {
            Button {
                moveAction(action, direction: -1)
            } label: {
                Image(systemName: "chevron.up")
                    .font(.system(size: 10))
                    .foregroundColor(index == 0 ? Theme.Colors.textTertiary.opacity(0.4) : Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(index == 0)

            Button {
                moveAction(action, direction: 1)
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(index == actions.count - 1 ? Theme.Colors.textTertiary.opacity(0.4) : Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(index == actions.count - 1)
        }
    }

    // MARK: - New Action Form

    private var newActionForm: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            HStack {
                Text("New Action")
                    .font(Theme.Typography.body(14))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                Button {
                    withAnimation(Theme.Motion.standard) {
                        resetNewAction()
                    }
                } label: {
                    Text("Cancel")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            inlineFieldSection("NAME") {
                TextField("Action name", text: $newName)
                    .inputFieldStyle()
            }

            inlineFieldSection("PROMPT") {
                TextEditor(text: $newPrompt)
                    .font(Theme.Typography.body(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 60, maxHeight: 100)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            }

            inlineFieldSection("HOTKEY") {
                HotkeyRecorderView(keyCode: $newHotkeyKeyCode, modifiers: $newHotkeyModifiers)
            }

            inlineFieldSection("OUTPUT") {
                Picker("", selection: $newOutputBehavior) {
                    ForEach(OutputBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.rawValue.capitalized).tag(behavior)
                    }
                }
                .pickerStyle(.segmented)
            }

            HStack {
                Spacer()
                Button {
                    createAction()
                } label: {
                    Text("Create Action")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
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
                    expandedActionID = nil
                    isCreatingNew = true
                }
            } label: {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                    Text("New Action")
                        .font(Theme.Typography.label(12))
                }
                .foregroundColor(Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(isCreatingNew)

            Spacer()

            Button {
                showRestoreConfirmation = true
            } label: {
                Text("Restore Defaults")
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func inlineFieldSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.allCaps(9))
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(1)
            content()
        }
    }

    private func moveAction(_ action: Action, direction: Int) {
        let sorted = actions.sorted { $0.sortOrder < $1.sortOrder }
        guard let currentIndex = sorted.firstIndex(where: { $0.id == action.id }) else { return }
        let newIndex = currentIndex + direction
        guard newIndex >= 0, newIndex < sorted.count else { return }

        let otherAction = sorted[newIndex]
        let tempOrder = action.sortOrder
        action.sortOrder = otherAction.sortOrder
        otherAction.sortOrder = tempOrder
        action.updatedAt = Date()
        otherAction.updatedAt = Date()
    }

    private func duplicateAction(_ action: Action) {
        let maxOrder = actions.map(\.sortOrder).max() ?? 0
        let newAction = Action(
            name: "\(action.name) Copy",
            prompt: action.prompt,
            outputBehavior: action.outputBehavior,
            providerMode: action.providerMode,
            providerID: action.providerID,
            modelOverride: action.modelOverride,
            enabled: action.enabled,
            sortOrder: maxOrder + 1
        )
        modelContext.insert(newAction)
        appCoordinator.refreshHotkeys()
    }

    private func deleteAction(_ action: Action) {
        modelContext.delete(action)
        appCoordinator.refreshHotkeys()
    }

    private func createAction() {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let descriptor = FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
        let maxOrder = (try? modelContext.fetch(descriptor).first?.sortOrder) ?? -1
        let action = Action(
            name: trimmedName,
            prompt: newPrompt,
            hotkeyKeyCode: newHotkeyKeyCode,
            hotkeyModifiers: newHotkeyModifiers,
            outputBehavior: newOutputBehavior,
            providerMode: newProviderMode,
            providerID: newProviderMode == .fixed ? newProviderID : nil,
            modelOverride: newModelOverride.isEmpty ? nil : newModelOverride,
            enabled: true,
            sortOrder: maxOrder + 1
        )
        modelContext.insert(action)
        appCoordinator.refreshHotkeys()

        withAnimation(Theme.Motion.standard) {
            resetNewAction()
        }
    }

    private func resetNewAction() {
        isCreatingNew = false
        newName = ""
        newPrompt = ""
        newHotkeyKeyCode = nil
        newHotkeyModifiers = nil
        newOutputBehavior = .replace
        newProviderMode = .active
        newProviderID = nil
        newModelOverride = ""
    }

    private func restoreDefaults() {
        expandedActionID = nil
        for action in actions {
            modelContext.delete(action)
        }

        let defaults = [
            Constants.DefaultActions.rewriteForClarity,
            Constants.DefaultActions.grammarFix,
            Constants.DefaultActions.paraphrase,
        ]

        for (index, def) in defaults.enumerated() {
            let action = Action(
                name: def.name,
                prompt: def.prompt,
                hotkeyKeyCode: def.keyCode,
                hotkeyModifiers: def.modifiers,
                outputBehavior: .replace,
                sortOrder: index
            )
            modelContext.insert(action)
        }
        appCoordinator.refreshHotkeys()
    }
}

// MARK: - Inline Editor (expanded state)

struct ActionInlineEditor: View {
    @Bindable var action: Action
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @Query(sort: \Provider.displayName) private var providers: [Provider]

    let onDelete: () -> Void
    let onDuplicate: () -> Void

    @State private var editingPrompt: String = ""
    @State private var editingModelOverride: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(height: 1)

            // Prompt
            fieldSection("PROMPT") {
                TextEditor(text: $editingPrompt)
                    .font(Theme.Typography.body(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 60, maxHeight: 100)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                    .onChange(of: editingPrompt) { _, newValue in
                        action.prompt = newValue
                        action.updatedAt = Date()
                    }
            }

            // Hotkey
            fieldSection("HOTKEY") {
                HotkeyRecorderView(
                    keyCode: Binding(
                        get: { action.hotkeyKeyCode },
                        set: {
                            action.hotkeyKeyCode = $0
                            action.updatedAt = Date()
                        }
                    ),
                    modifiers: Binding(
                        get: { action.hotkeyModifiers },
                        set: {
                            action.hotkeyModifiers = $0
                            action.updatedAt = Date()
                            appCoordinator.refreshHotkeys()
                        }
                    )
                )
            }

            // Output behavior
            fieldSection("OUTPUT") {
                Picker("", selection: Binding(
                    get: { action.outputBehavior },
                    set: { action.outputBehavior = $0; action.updatedAt = Date() }
                )) {
                    ForEach(OutputBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.rawValue.capitalized).tag(behavior)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Provider
            fieldSection("PROVIDER") {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Picker("", selection: Binding(
                        get: { action.providerMode },
                        set: { action.providerMode = $0; action.updatedAt = Date() }
                    )) {
                        Text("Use Active").tag(ProviderMode.active)
                        Text("Fixed Provider").tag(ProviderMode.fixed)
                    }
                    .pickerStyle(.segmented)

                    if action.providerMode == .fixed {
                        Picker("Provider", selection: Binding(
                            get: { action.providerID },
                            set: { action.providerID = $0; action.updatedAt = Date() }
                        )) {
                            Text("Select...").tag(nil as UUID?)
                            ForEach(providers) { provider in
                                Text(provider.displayName).tag(provider.id as UUID?)
                            }
                        }
                        .labelsHidden()
                    }

                    TextField("Model override (optional)", text: $editingModelOverride)
                        .inputFieldStyle()
                        .onChange(of: editingModelOverride) { _, newValue in
                            action.modelOverride = newValue.isEmpty ? nil : newValue
                            action.updatedAt = Date()
                        }
                }
            }

            // Actions row
            HStack(spacing: Theme.Spacing.lg) {
                Button {
                    onDuplicate()
                } label: {
                    Text("Duplicate")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    onDelete()
                } label: {
                    Text("Delete Action")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.bottom, Theme.Spacing.lg)
        .onAppear {
            editingPrompt = action.prompt
            editingModelOverride = action.modelOverride ?? ""
        }
    }

    private func fieldSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.allCaps(9))
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(1)
            content()
        }
    }
}
