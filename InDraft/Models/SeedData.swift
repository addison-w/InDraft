import Foundation
import SwiftData

enum SeedData {
    static func createDefaultActions(in context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Action>())) ?? []
        guard existing.isEmpty else { return }

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
            context.insert(action)
        }

        try? context.save()
    }

    static func restoreDefaultActions(in context: ModelContext) {
        let defaults: [(name: String, prompt: String, keyCode: UInt32, modifiers: UInt32)] = [
            Constants.DefaultActions.rewriteForClarity,
            Constants.DefaultActions.grammarFix,
            Constants.DefaultActions.paraphrase,
        ]

        let allActions = (try? context.fetch(FetchDescriptor<Action>())) ?? []

        for def in defaults {
            if let existing = allActions.first(where: { $0.name == def.name }) {
                existing.prompt = def.prompt
                existing.hotkeyKeyCode = def.keyCode
                existing.hotkeyModifiers = def.modifiers
                existing.outputBehavior = .replace
                existing.updatedAt = Date()
            } else {
                let action = Action(
                    name: def.name,
                    prompt: def.prompt,
                    hotkeyKeyCode: def.keyCode,
                    hotkeyModifiers: def.modifiers,
                    outputBehavior: .replace,
                    sortOrder: allActions.count
                )
                context.insert(action)
            }
        }

        try? context.save()
    }
}
