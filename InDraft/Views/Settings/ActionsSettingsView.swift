import SwiftUI
import SwiftData
import Hugeicons

struct ActionsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @State private var expandedActionID: UUID?
    @State private var confirmingRestore = false
    @State private var draggingActionID: UUID?
    @State private var searchText = ""

    // Inline new action state
    @State private var isCreatingNew = false
    @State private var newName = ""
    @State private var newPrompt = ""
    @State private var newHotkeyKeyCode: UInt32?
    @State private var newHotkeyModifiers: UInt32?
    @State private var newOutputBehavior: OutputBehavior = .replace

    private var filteredActions: [Action] {
        if searchText.isEmpty { return actions }
        return actions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

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
        .onChange(of: confirmingRestore) { _, confirming in
            if confirming {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(Theme.Motion.quick) { confirmingRestore = false }
                }
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            Text("Actions")
                .font(Theme.Typography.pageTitle())
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            HStack(spacing: Theme.Spacing.sm) {
                AppIcon.search.image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Theme.Colors.textTertiary)

                TextField("Search actions...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(Theme.Typography.body(12))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(width: 120)
            }
            .padding(.horizontal, Theme.Spacing.sm + 2)
            .padding(.vertical, Theme.Spacing.xs + 2)
            .background(Theme.Colors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Actions List

    private var actionsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredActions.enumerated()), id: \.element.id) { index, action in
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
        .onDrop(of: [.text], isTargeted: nil) { _ in
            draggingActionID = nil
            return false
        }
    }

    // MARK: - Collapsed Row

    private func actionRow(_ action: Action, index: Int) -> some View {
        let isExpanded = expandedActionID == action.id

        return VStack(alignment: .leading, spacing: 0) {
            // Header row — always visible
            HStack(spacing: 0) {
                // Drag handle
                AppIcon.dragHandle.image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
                    .foregroundColor(Theme.Colors.textTertiary.opacity(0.5))
                    .frame(width: 24, height: 44)
                    .contentShape(Rectangle())
                    .padding(.leading, Theme.Spacing.md)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.openHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onDrag {
                        NSCursor.closedHand.set()
                        draggingActionID = action.id
                        let provider = NSItemProvider()
                        provider.registerDataRepresentation(
                            forTypeIdentifier: "public.plain-text",
                            visibility: .ownProcess
                        ) { completion in
                            completion(action.id.uuidString.data(using: .utf8), nil)
                            return nil
                        }
                        return provider
                    }

                // Clickable row content
                Button {
                    withAnimation(Theme.Motion.standard) {
                        expandedActionID = isExpanded ? nil : action.id
                    }
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text(action.name)
                                .font(Theme.Typography.body(14))
                                .fontWeight(.medium)
                                .foregroundColor(Theme.Colors.textPrimary)

                            HStack(spacing: Theme.Spacing.sm) {
                                if action.hasHotkey,
                                   let kc = action.hotkeyKeyCode,
                                   let mods = action.hotkeyModifiers {
                                    KeycapRow(keyCode: kc, modifiers: mods, size: 9)
                                }

                                Text(action.outputBehavior.rawValue.uppercased())
                                    .font(Theme.Typography.allCaps(9))
                                    .foregroundColor(Theme.Colors.textTertiary)
                                    .tracking(0.5)
                                    .padding(.horizontal, Theme.Spacing.sm)
                                    .padding(.vertical, 2)
                                    .background(Theme.Colors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                            .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                                    )
                            }
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { action.enabled },
                            set: { newValue in
                                action.enabled = newValue
                                action.updatedAt = Date()
                                appCoordinator.refreshHotkeys()
                            }
                        ))
                        .toggleStyle(WabiSabiToggleStyle())
                        .labelsHidden()

                        AppIcon.chevronRight.image()
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Theme.Colors.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .opacity(draggingActionID == action.id ? 0.4 : 1.0)
            .onDrop(of: [.text], delegate: ActionDropDelegate(
                targetAction: action,
                actions: actions,
                draggingActionID: $draggingActionID,
                moveAction: moveAction
            ))

            // Expanded inline editor
            if isExpanded {
                ActionInlineEditor(
                    action: action,
                    onDelete: {
                        withAnimation(Theme.Motion.standard) {
                            expandedActionID = nil
                            deleteAction(action)
                        }
                    },
                    onDuplicate: {
                        duplicateAction(action)
                    }
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - New Action Form

    private var newActionForm: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
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

            // NAME — full width
            inlineFieldSection("NAME") {
                TextField("Action name", text: $newName)
                    .inputFieldStyle()
            }

            // PROMPT — full width
            inlineFieldSection("PROMPT") {
                TextEditor(text: $newPrompt)
                    .font(Theme.Typography.body(13))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 88, maxHeight: 160)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                    )
            }

            // HOTKEY + OUTPUT — side by side
            HStack(alignment: .top, spacing: Theme.Spacing.xxl) {
                inlineFieldSection("HOTKEY") {
                    HotkeyRecorderView(keyCode: $newHotkeyKeyCode, modifiers: $newHotkeyModifiers)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                inlineFieldSection("OUTPUT") {
                    InkSegmentPicker(
                        options: OutputBehavior.allCases.map { ($0.rawValue.capitalized, $0) },
                        selection: $newOutputBehavior
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Spacer()
                Button {
                    createAction()
                } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        AppIcon.add.image()
                            .resizable()
                            .scaledToFit()
                            .frame(width: 11, height: 11)
                        Text("Create Action")
                            .font(Theme.Typography.label(11))
                    }
                    .foregroundColor(Theme.Colors.textPrimary)
                }
                .buttonStyle(.plain)
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
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
                    AppIcon.add.image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                    Text("New Action")
                        .font(Theme.Typography.label(12))
                }
                .foregroundColor(Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(isCreatingNew)

            Spacer()

            Button {
                if confirmingRestore {
                    confirmingRestore = false
                    restoreDefaults()
                } else {
                    withAnimation(Theme.Motion.quick) { confirmingRestore = true }
                }
            } label: {
                Text(confirmingRestore ? "Confirm restore?" : "Restore Defaults")
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(confirmingRestore ? Theme.Colors.error : Theme.Colors.textTertiary)
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
    }

    private func restoreDefaults() {
        expandedActionID = nil
        for action in actions {
            modelContext.delete(action)
        }

        let defaults = [
            Constants.DefaultActions.grammarFix,
            Constants.DefaultActions.rewriteForClarity,
            Constants.DefaultActions.shorten,
            Constants.DefaultActions.translateToEnglish,
            Constants.DefaultActions.professionalTone,
            Constants.DefaultActions.eli5,
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

    @State private var editingName: String = ""
    @State private var editingPrompt: String = ""
    @State private var confirmingDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(height: 1)
                .padding(.horizontal, Theme.Spacing.xl)

            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // NAME — full width
                fieldSection("NAME") {
                    TextField("Action name", text: $editingName)
                        .inputFieldStyle()
                        .onChange(of: editingName) { _, newValue in
                            action.name = newValue
                            action.updatedAt = Date()
                        }
                }

                // PROMPT — full width, generous height
                fieldSection("PROMPT") {
                    TextEditor(text: $editingPrompt)
                        .font(Theme.Typography.body(13))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 88, maxHeight: 160)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.md)
                                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                        )
                        .onChange(of: editingPrompt) { _, newValue in
                            action.prompt = newValue
                            action.updatedAt = Date()
                        }
                }

                // HOTKEY + OUTPUT — side by side
                HStack(alignment: .top, spacing: Theme.Spacing.xxl) {
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
                    .frame(maxWidth: .infinity, alignment: .leading)

                    fieldSection("OUTPUT") {
                        InkSegmentPicker(
                            options: OutputBehavior.allCases.map { ($0.rawValue.capitalized, $0) },
                            selection: Binding(
                                get: { action.outputBehavior },
                                set: { action.outputBehavior = $0; action.updatedAt = Date() }
                            )
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // PROVIDER
                fieldSection("PROVIDER") {
                    InkSegmentPicker(
                        options: ProviderMode.allCases.map { ($0 == .active ? "Active" : "Fixed", $0) },
                        selection: Binding(
                            get: { action.providerMode },
                            set: {
                                action.providerMode = $0
                                if $0 == .active {
                                    action.providerID = nil
                                    action.modelOverride = nil
                                }
                                action.updatedAt = Date()
                            }
                        )
                    )
                }

                // CONFIGURATION — only when Fixed
                if action.providerMode == .fixed {
                    let enabledProviders = providers.filter { $0.enabled }

                    if enabledProviders.isEmpty {
                        fieldSection("CONFIGURATION") {
                            Text("No providers available")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.error)
                        }
                    } else {
                        HStack(alignment: .top, spacing: Theme.Spacing.xxl) {
                            fieldSection("PROVIDER") {
                                Menu {
                                    Button {
                                        action.providerID = nil
                                        action.updatedAt = Date()
                                    } label: {
                                        if action.providerID == nil {
                                            Label("None", systemImage: "checkmark")
                                        } else {
                                            Text("None")
                                        }
                                    }

                                    Divider()

                                    ForEach(enabledProviders, id: \.id) { provider in
                                        Button {
                                            action.providerID = provider.id
                                            action.updatedAt = Date()
                                        } label: {
                                            if action.providerID == provider.id {
                                                Label(provider.displayName, systemImage: "checkmark")
                                            } else {
                                                Text(provider.displayName)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: Theme.Spacing.sm) {
                                        Text(providerLabel(for: action, providers: enabledProviders))
                                            .font(Theme.Typography.body(13))
                                            .foregroundColor(action.providerID == nil
                                                ? Theme.Colors.textTertiary
                                                : Theme.Colors.textPrimary)

                                        Spacer()

                                        AppIcon.chevronRight.image()
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 9, height: 9)
                                            .foregroundColor(Theme.Colors.textTertiary)
                                            .rotationEffect(.degrees(90))
                                    }
                                    .padding(.horizontal, Theme.Spacing.md)
                                    .padding(.vertical, Theme.Spacing.sm + 2)
                                    .background(Theme.Colors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                                            .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                                    )
                                }
                                .menuStyle(.borderlessButton)
                                .menuIndicator(.hidden)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            fieldSection("MODEL OVERRIDE") {
                                TextField("Model override", text: Binding(
                                    get: { action.modelOverride ?? "" },
                                    set: {
                                        action.modelOverride = $0.isEmpty ? nil : $0
                                        action.updatedAt = Date()
                                    }
                                ))
                                .inputFieldStyle()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                // Actions row
                HStack {
                    Button {
                        onDuplicate()
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            AppIcon.copy.image()
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                            Text("Duplicate")
                                .font(Theme.Typography.label(11))
                        }
                        .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .buttonStyle(.plain)

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
                        HStack(spacing: Theme.Spacing.xs) {
                            AppIcon.close.image()
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                            Text(confirmingDelete ? "Confirm delete?" : "Delete Action")
                                .font(Theme.Typography.label(11))
                        }
                        .foregroundColor(Theme.Colors.error)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.lg)
        }
        .onAppear {
            editingName = action.name
            editingPrompt = action.prompt
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

    private func providerLabel(for action: Action, providers: [Provider]) -> String {
        guard let id = action.providerID,
              let provider = providers.first(where: { $0.id == id }) else {
            return "Select provider\u{2026}"
        }
        return provider.displayName
    }
}

// MARK: - Drag & Drop Delegate

struct ActionDropDelegate: DropDelegate {
    let targetAction: Action
    let actions: [Action]
    @Binding var draggingActionID: UUID?
    let moveAction: (Action, Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        draggingActionID = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingID = draggingActionID,
              draggingID != targetAction.id else { return }

        let sorted = actions.sorted { $0.sortOrder < $1.sortOrder }
        guard let fromIndex = sorted.firstIndex(where: { $0.id == draggingID }),
              let toIndex = sorted.firstIndex(where: { $0.id == targetAction.id }) else { return }

        if fromIndex != toIndex {
            withAnimation(Theme.Motion.standard) {
                let direction = fromIndex < toIndex ? 1 : -1
                moveAction(sorted[fromIndex], direction)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
