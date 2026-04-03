import SwiftUI
import SwiftData

struct ActionsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @State private var isReordering = false
    @State private var editingAction: Action?
    @State private var isCreatingNew = false
    @State private var showRestoreConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                headerRow

                actionsList

                bottomBar
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .sheet(item: $editingAction) { action in
            ActionEditorView(action: action, isNew: false)
        }
        .sheet(isPresented: $isCreatingNew) {
            ActionEditorView(action: nil, isNew: true)
        }
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
        HStack(alignment: .top) {
            Text("Actions")
                .font(Theme.Typography.pageTitle())
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            Button {
                isReordering.toggle()
            } label: {
                Text(isReordering ? "DONE" : "REORDER")
                    .font(Theme.Typography.allCaps(10))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.sm)
                            .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions List

    private var actionsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                if index > 0 {
                    Divider()
                        .foregroundColor(Theme.Colors.divider)
                        .padding(.horizontal, Theme.Spacing.lg)
                }
                actionRow(action, index: index)
            }
        }
        .cardStyle()
    }

    private func actionRow(_ action: Action, index: Int) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            if isReordering {
                VStack(spacing: 2) {
                    Button {
                        moveAction(action, direction: -1)
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 10))
                            .foregroundColor(index == 0 ? Theme.Colors.textTertiary : Theme.Colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(index == 0)

                    Button {
                        moveAction(action, direction: 1)
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(index == actions.count - 1 ? Theme.Colors.textTertiary : Theme.Colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(index == actions.count - 1)
                }
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(action.name)
                    .font(Theme.Typography.body(14))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textPrimary)

                HStack(spacing: Theme.Spacing.sm) {
                    if action.hasHotkey {
                        Text(action.hotkeyDisplayString)
                            .font(Theme.Typography.mono(10))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, 3)
                            .background(Theme.Colors.badgeBackground)
                            .clipShape(Capsule())
                    }

                    Text(action.outputBehavior.rawValue.uppercased())
                        .font(Theme.Typography.allCaps(9))
                        .foregroundColor(Theme.Colors.textTertiary)
                        .tracking(0.5)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(outputBehaviorColor(action.outputBehavior))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { action.enabled },
                set: { newValue in
                    action.enabled = newValue
                    action.updatedAt = Date()
                }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)

            Menu {
                Button("Edit") {
                    editingAction = action
                }
                Button("Duplicate") {
                    duplicateAction(action)
                }
                Divider()
                Button("Delete", role: .destructive) {
                    deleteAction(action)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.vertical, Theme.Spacing.lg)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            editingAction = action
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button {
                isCreatingNew = true
            } label: {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                    Text("New Action")
                        .font(Theme.Typography.label(13))
                }
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showRestoreConfirmation = true
            } label: {
                Text("Restore Defaults")
                    .font(Theme.Typography.body(12))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .underline(color: Theme.Colors.textTertiary.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func outputBehaviorColor(_ behavior: OutputBehavior) -> Color {
        switch behavior {
        case .replace: return Theme.Colors.badgeBackground
        case .preview: return Theme.Colors.accent.opacity(0.15)
        case .clipboard: return Theme.Colors.statusAmber.opacity(0.15)
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
    }

    private func deleteAction(_ action: Action) {
        modelContext.delete(action)
    }

    private func restoreDefaults() {
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
    }
}
