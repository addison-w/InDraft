# Tasks: Redesign App Spacing

## 1. Foundation (Theme.swift)

- [x] 1.1 Update Theme.Spacing enum with new scale values (xs: 6, sm: 12, md: 20, lg: 28, xl: 40, xxl: 56, xxxl: 80)
- [x] 1.2 Add line height values to Theme.Typography (headline: 1.2, sectionTitle: 1.3, body: 1.5, label: 1.4, mono: 1.4, caption: 1.4, allCaps: 1.2)
- [x] 1.3 Add static cardPadding property returning EdgeInsets(top: 24, leading: 28, bottom: 24, trailing: 28)
- [x] 1.4 Add static sectionPadding property for common section margins

## 2. MenuBar Dropdown Views

- [x] 2.1 Update MenuBarDropdownView width from 260pt to 300pt
- [x] 2.2 Update MenuBarRowView vertical padding from 6pt to 10pt minimum
- [x] 2.3 Update thematicDivider padding to use Theme.Spacing.md instead of Theme.Spacing.xs
- [x] 2.4 Update headerSection padding to use Theme.Spacing.lg for horizontal

## 3. Settings Views

- [x] 3.1 Update SettingsView sidebar minimum width from 140pt to 180pt
- [x] 3.2 Update sidebar item padding to use Theme.Spacing.lg horizontal and Theme.Spacing.md vertical
- [x] 3.3 Update ActionsSettingsView ScrollView padding to Theme.Spacing.xl
- [x] 3.4 Update ActionsSettingsView action row padding to Theme.Spacing.xl horizontal, Theme.Spacing.lg vertical
- [x] 3.5 Update ActionsSettingsView actionsList spacing from 0 to Theme.Spacing.md
- [x] 3.6 Apply Theme.cardPadding to actionsList card container
- [x] 3.7 Update ProvidersSettingsView with consistent spacing
- [x] 3.8 Update GeneralSettingsView form spacing to Theme.Spacing.md minimum
- [x] 3.9 Update HistorySettingsView list spacing

## 4. History Window

- [x] 4.1 Update HistoryWindowView record list spacing from Theme.Spacing.xs to Theme.Spacing.md
- [x] 4.2 Update top bar padding to Theme.Spacing.lg horizontal, Theme.Spacing.md vertical
- [x] 4.3 Update HistoryRecordRowView internal padding to Theme.Spacing.lg

## 5. Onboarding Views

- [x] 5.1 Update OnboardingContainerView frame from 500×450 to 540×480
- [x] 5.2 Update step content horizontal padding to Theme.Spacing.xl
- [x] 5.3 Update navigation bar padding to Theme.Spacing.xl
- [x] 5.4 Update step indicator top padding to Theme.Spacing.xl
- [x] 5.5 Review and update individual step views (WelcomeStepView, AccessibilityStepView, etc.) for consistent spacing

## 6. Additional Views

- [x] 6.1 Update PreviewPanelView padding and spacing
- [x] 6.2 Update ToastView spacing
- [x] 6.3 Update ProviderEditorView form spacing
- [x] 6.4 Update ActionEditorView form spacing
- [x] 6.5 Update HotkeyRecorderView spacing

## 7. Verification

- [x] 7.1 Build and run the app
- [x] 7.2 Take screenshot of MenuBarDropdown before/after comparison
- [x] 7.3 Take screenshot of Settings window before/after comparison
- [x] 7.4 Take screenshot of History window before/after comparison
- [x] 7.5 Take screenshot of Onboarding flow before/after comparison
- [x] 7.6 Verify all interactive elements remain accessible and usable
- [x] 7.7 Test keyboard navigation still works correctly