## ADDED Requirements

### Requirement: Action data model
Each action SHALL store: id (auto-generated), name (max 50 chars), prompt (max 2000 chars), hotkey, output_behavior (replace|preview|clipboard), provider_mode (active|fixed), provider_id (nullable), model_override (nullable), enabled (boolean), sort_order (integer), created_at, updated_at.

#### Scenario: Create action with all fields
- **WHEN** a new action is created with name, prompt, and output behavior
- **THEN** the action is persisted with auto-generated id, timestamps, enabled=true, and sort_order appended to end

### Requirement: Three default actions ship with the app
The app SHALL include 3 pre-configured default actions: "Rewrite for Clarity" (Control+Option+1, replace), "Grammar Fix" (Control+Option+2, replace), "Paraphrase" (Control+Option+3, replace).

#### Scenario: Default actions present on first launch
- **WHEN** the app is launched for the first time
- **THEN** 3 default actions exist with their pre-configured names, prompts, hotkeys, and replace output behavior

### Requirement: Action CRUD operations
Users SHALL be able to create, edit, duplicate, and delete actions.

#### Scenario: Create custom action
- **WHEN** the user clicks "+ New Action" and fills in name and prompt
- **THEN** a new action is created and appears in the action list

#### Scenario: Edit existing action
- **WHEN** the user opens an action in the editor and modifies fields
- **THEN** the changes are saved and take effect immediately

#### Scenario: Duplicate action
- **WHEN** the user duplicates an action
- **THEN** a new action is created with all fields copied and name suffixed with "(Copy)"

#### Scenario: Delete custom action
- **WHEN** the user deletes an action AND confirms the deletion
- **THEN** the action is removed AND its hotkey is deregistered AND its history records are preserved

### Requirement: Action enable/disable toggle
Users SHALL be able to enable or disable any action. Disabled actions SHALL not respond to hotkeys.

#### Scenario: Disable action
- **WHEN** the user toggles an action to disabled
- **THEN** the action's hotkey is deregistered AND the action does not appear in the menu bar dropdown actions list

#### Scenario: Enable action
- **WHEN** the user toggles an action to enabled
- **THEN** the action's hotkey is registered AND the action appears in the menu bar dropdown

### Requirement: Action reordering
Users SHALL be able to reorder actions. The order determines display order in the menu bar dropdown and settings list.

#### Scenario: Reorder actions
- **WHEN** the user reorders actions via drag or move up/down
- **THEN** the sort_order is updated AND the menu bar dropdown reflects the new order

### Requirement: Restore defaults
"Restore Defaults" SHALL reset the 3 built-in actions to their original values without deleting custom actions.

#### Scenario: Restore default actions
- **WHEN** the user clicks "Restore Defaults" in Settings > Actions
- **THEN** the 3 default actions are reset to original name, prompt, hotkey, and output behavior AND custom actions remain unchanged

### Requirement: Output behavior modes
Each action SHALL have one of three output behaviors: replace (in-place replacement), preview (show preview panel before applying), clipboard (copy to clipboard only).

#### Scenario: Replace mode
- **WHEN** a transformation completes for an action with replace output behavior
- **THEN** the selected text is replaced in place immediately

#### Scenario: Preview mode
- **WHEN** a transformation completes for an action with preview output behavior
- **THEN** the preview panel opens showing original and transformed text

#### Scenario: Clipboard mode
- **WHEN** a transformation completes for an action with clipboard output behavior
- **THEN** the transformed text is copied to clipboard AND "Result copied to clipboard" notification is shown AND original text is not modified

### Requirement: Action provider mode
Each action SHALL support two provider modes: "active" (uses the global active provider) and "fixed" (uses a specific assigned provider).

#### Scenario: Action uses active provider
- **WHEN** a transformation triggers for an action with provider_mode=active
- **THEN** the request is sent to the currently active global provider

#### Scenario: Action uses fixed provider
- **WHEN** a transformation triggers for an action with provider_mode=fixed
- **THEN** the request is sent to the action's assigned provider regardless of the active provider

#### Scenario: Fixed provider deleted
- **WHEN** a provider is deleted that was assigned to an action as fixed
- **THEN** the action's provider_id is set to null AND provider_mode is switched to active

### Requirement: Action validation
Action name SHALL be required and unique. Prompt SHALL be required. Hotkey SHALL be optional.

#### Scenario: Attempt to save action without name
- **WHEN** the user attempts to save an action with an empty name
- **THEN** validation fails and an error is shown on the name field

#### Scenario: Action without hotkey is usable via menu
- **WHEN** an action has no hotkey assigned
- **THEN** the action appears in the menu bar dropdown and can be triggered from there
