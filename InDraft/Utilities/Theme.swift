import SwiftUI
import AppKit

// MARK: - NSColor Hex Extension

extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            srgbRed: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

enum Theme {
    // MARK: - Adaptive Color Helper

    private static func adaptive(light: String, dark: String) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
            return isDark ? NSColor(hex: dark) : NSColor(hex: light)
        }))
    }

    private static func adaptive(light: String, lightAlpha: CGFloat = 1, dark: String, darkAlpha: CGFloat = 1) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
            let color = isDark ? NSColor(hex: dark) : NSColor(hex: light)
            let alpha = isDark ? darkAlpha : lightAlpha
            return color.withAlphaComponent(alpha)
        }))
    }

    // MARK: - Colors (from DESIGN.md — "High-End Utilitarian Editorial")

    enum Colors {
        /// Primary background — warm bone / deep warm charcoal
        static let background = adaptive(light: "FAF9F6", dark: "111311")
        /// Card/container background — clear step above canvas
        static let cardBackground = adaptive(light: "FFFFFF", dark: "1A1C1A")
        /// Card border — visible editorial border
        static let cardBorder = adaptive(light: "AFB3AE", lightAlpha: 0.15, dark: "4A4D4A", darkAlpha: 0.4)
        /// Primary text
        static let textPrimary = adaptive(light: "2F3430", dark: "E8E8E4")
        /// Secondary text
        static let textSecondary = adaptive(light: "5C605C", dark: "9EA29E")
        /// Tertiary text — labels, metadata
        static let textTertiary = adaptive(light: "777C77", dark: "6E726E")
        /// Accent — pale blue
        static let accent = adaptive(light: "51616B", dark: "8AACB8")
        /// Accent container
        static let accentContainer = adaptive(light: "D3E5F0", dark: "1A2A32")
        /// Error
        static let error = adaptive(light: "9F403D", dark: "D4645F")
        /// Error container
        static let errorContainer = adaptive(light: "FE8983", dark: "2E1A1A")
        /// Badge background
        static let badgeBackground = adaptive(light: "F4F3F3", dark: "252725")
        /// Divider — visible but refined
        static let divider = adaptive(light: "AFB3AE", lightAlpha: 0.15, dark: "4A4D4A", darkAlpha: 0.25)
        /// Surface container — sidebar background
        static let surfaceContainer = adaptive(light: "EDEEEA", dark: "161816")
        /// Surface container high — selected/hover states
        static let surfaceContainerHigh = adaptive(light: "E6E9E4", dark: "2A2C2A")
        /// Surface container low — input fields, recessed areas
        static let surfaceContainerLow = adaptive(light: "F4F4F0", dark: "222422")
        /// Primary button background
        static let primary = adaptive(light: "5A5F62", dark: "6A7074")
        /// On primary — text on primary buttons
        static let onPrimary = adaptive(light: "F4F8FC", dark: "F4F8FC")
        /// Inverse surface
        static let inverseSurface = adaptive(light: "0D0F0D", dark: "E8E8E4")

        // MARK: Semantic Status Colors
        static let statusGreen = adaptive(light: "3A7D44", dark: "5AAF66")
        static let statusGreenBg = adaptive(light: "EDF3EC", dark: "1A2E1A")
        static let statusGreenText = adaptive(light: "346538", dark: "5AAF66")
        static let statusAmber = adaptive(light: "C4930A", dark: "D4A82A")
        static let statusAmberBg = adaptive(light: "FBF3DB", dark: "2E2A1A")
        static let statusAmberText = adaptive(light: "956400", dark: "D4A82A")
        static let statusRed = adaptive(light: "9F2F2D", dark: "D4645F")
        static let statusRedBg = adaptive(light: "FDEBEC", dark: "2E1A1A")
        static let statusBlue = adaptive(light: "4A7FB5", dark: "8AACB8")
        static let statusBlueBg = adaptive(light: "4A7FB5", lightAlpha: 0.1, dark: "8AACB8", darkAlpha: 0.12)

        // MARK: Window Controls
        static let windowControlDefault = adaptive(light: "C8C8C5", dark: "3A3D3A")
        static let windowControlClose = adaptive(light: "E8706B", dark: "E8706B")
        static let windowControlMinimize = adaptive(light: "E5BF4B", dark: "E5BF4B")
        static let windowControlZoom = adaptive(light: "6BBF6A", dark: "6BBF6A")
        static let windowControlIcon = adaptive(light: "3A3A38", lightAlpha: 0.85, dark: "1A1A18", darkAlpha: 0.85)

        // MARK: Diff Highlighting
        static let diffInsertedBg = adaptive(light: "D4EDDA", dark: "1A2E1A")
        static let diffInsertedText = adaptive(light: "1B5E20", dark: "5AAF66")
        static let diffRemovedBg = adaptive(light: "F8D7DA", dark: "2E1A1A")
        static let diffRemovedText = adaptive(light: "9F2F2D", dark: "D4645F")
    }

    // MARK: - Typography (SF Rounded — Japanese modern minimalist)
    //
    // All text uses SF Rounded — soft terminals, warm yet geometric.
    // Evokes the feel of modern Japanese product design (MUJI, LINE).
    // Titles use light weight for airy quality. Body regular. Labels medium.

    enum Typography {
        /// Page title — light weight, generous size, architectural calm
        static func pageTitle(_ size: CGFloat = 22) -> Font {
            .system(size: size, design: .rounded).weight(.light)
        }

        /// Section title — light weight, restrained scale
        static func sectionTitle(_ size: CGFloat = 16) -> Font {
            .system(size: size, design: .rounded).weight(.light)
        }

        /// Body text — regular weight for clean readability
        static func body(_ size: CGFloat = 13) -> Font {
            .system(size: size, design: .rounded)
        }

        /// Label text — medium weight for quiet emphasis
        static func label(_ size: CGFloat = 11) -> Font {
            .system(size: size, design: .rounded).weight(.medium)
        }

        /// Monospaced — SF Mono for keyboard shortcuts and technical data
        static func mono(_ size: CGFloat = 11) -> Font {
            .system(size: size, design: .monospaced)
        }

        /// Caption — light weight, delicate
        static func caption(_ size: CGFloat = 10) -> Font {
            .system(size: size, design: .rounded).weight(.light)
        }

        /// All caps label — medium weight for tracking
        static func allCaps(_ size: CGFloat = 10) -> Font {
            .system(size: size, design: .rounded).weight(.medium)
        }

        /// Brand name — semibold with wide tracking for quiet prominence
        static func brand(_ size: CGFloat = 15) -> Font {
            .system(size: size, design: .rounded).weight(.semibold)
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius (standard 8px per DESIGN.md)

    enum Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let full: CGFloat = 999
    }

    // MARK: - Illustrations (wabi-sabi ink-line art)

    enum Illustrations {
        /// Ink stroke color — textPrimary at 80% opacity for soft, hand-drawn feel
        static let inkStroke = Theme.Colors.textPrimary.opacity(0.8)
        /// Minimum stroke width for variation
        static let strokeWidthMin: CGFloat = 1.0
        /// Maximum stroke width for variation
        static let strokeWidthMax: CGFloat = 2.0
        /// Standard illustration height
        static let illustrationHeight: CGFloat = 80
    }

    // MARK: - Onboarding Layout

    enum OnboardingLayout {
        /// Maximum content width for centered onboarding screens
        static let contentMaxWidth: CGFloat = 420
        /// Step indicator dot diameter
        static let dotSize: CGFloat = 6
    }

    // MARK: - Animation

    enum Motion {
        /// Quick state change — hover, toggle (120ms)
        static let quick: Animation = .easeOut(duration: 0.12)
        /// Standard transition — expand, collapse (200ms)
        static let standard: Animation = .easeOut(duration: 0.2)
        /// Gentle entrance — sheet, panel (300ms)
        static let gentle: Animation = .easeOut(duration: 0.3)
    }
}

// MARK: - Color Hex Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Appearance Modifier

struct AppearanceModifier: ViewModifier {
    @AppStorage(Constants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = AppearanceMode.system.rawValue
    @State private var resolvedScheme: ColorScheme = .light

    private let systemAppearanceChanged = DistributedNotificationCenter.default()
        .publisher(for: Notification.Name("AppleInterfaceThemeChangedNotification"))

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(resolvedScheme)
            .onChange(of: appearanceMode) { _, newValue in
                applyAppearance(newValue)
            }
            .onReceive(systemAppearanceChanged) { _ in
                if AppearanceMode(rawValue: appearanceMode) == .system {
                    resolvedScheme = detectSystemColorScheme()
                }
            }
            .onAppear {
                applyAppearance(appearanceMode)
            }
    }

    private func applyAppearance(_ mode: String) {
        switch AppearanceMode(rawValue: mode) {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
            resolvedScheme = .light
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
            resolvedScheme = .dark
        case .system, .none:
            NSApp.appearance = nil
            resolvedScheme = detectSystemColorScheme()
        }
    }

    private func detectSystemColorScheme() -> ColorScheme {
        UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? .dark : .light
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
            )
            .shadow(color: Theme.Colors.textPrimary.opacity(0.03), radius: 8, y: 2)
    }
}

struct InputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .font(Theme.Typography.body(14))
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
            )
    }
}

struct BadgeStyle: ViewModifier {
    var color: Color = Theme.Colors.badgeBackground

    func body(content: Content) -> some View {
        content
            .font(Theme.Typography.caption())
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 2)
            .background(color)
            .clipShape(Capsule())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.label(13))
            .foregroundColor(Theme.Colors.onPrimary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.label(13))
            .foregroundColor(Theme.Colors.textPrimary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Colors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func inputFieldStyle() -> some View {
        modifier(InputFieldStyle())
    }

    func badgeStyle(color: Color = Theme.Colors.badgeBackground) -> some View {
        modifier(BadgeStyle(color: color))
    }
}

// MARK: - Wabi-Sabi Toggle Style

struct WabiSabiToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(configuration.isOn ? Theme.Colors.textSecondary : Theme.Colors.surfaceContainerHigh)
                    .frame(width: 28, height: 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Theme.Colors.divider, lineWidth: 1)
                    )

                Circle()
                    .fill(configuration.isOn ? Theme.Colors.cardBackground : Theme.Colors.textTertiary)
                    .frame(width: 12, height: 12)
                    .padding(.horizontal, 1)
                    .shadow(color: Color.black.opacity(0.06), radius: 1, y: 1)
            }
            .animation(Theme.Motion.quick, value: configuration.isOn)
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Ink Segment Picker

struct InkSegmentPicker<T: Hashable>: View {
    let options: [(label: String, value: T)]
    @Binding var selection: T

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let isSelected = selection == option.value

                Button {
                    withAnimation(Theme.Motion.quick) {
                        selection = option.value
                    }
                } label: {
                    Text(option.label)
                        .font(Theme.Typography.label(11))
                        .foregroundColor(isSelected ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.xs + 2)
                        .background(isSelected ? Theme.Colors.surfaceContainerLow : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                .stroke(isSelected ? Theme.Colors.cardBorder : Color.clear, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Keycap Views

/// Individual keycap — bordered box with monospace text, like a physical key
struct Keycap: View {
    let label: String
    var size: CGFloat = 11

    var body: some View {
        Text(label)
            .font(Theme.Typography.mono(size))
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(minWidth: size * 1.8)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 0, y: 1)
    }
}

/// Renders a hotkey as a row of individual keycaps
struct KeycapRow: View {
    let keyCode: UInt32
    let modifiers: UInt32
    var size: CGFloat = 11

    var body: some View {
        HStack(spacing: 4) {
            if modifiers & UInt32(NSEvent.ModifierFlags.control.rawValue) != 0 {
                Keycap(label: "\u{2303}", size: size)
            }
            if modifiers & UInt32(NSEvent.ModifierFlags.option.rawValue) != 0 {
                Keycap(label: "\u{2325}", size: size)
            }
            if modifiers & UInt32(NSEvent.ModifierFlags.shift.rawValue) != 0 {
                Keycap(label: "\u{21E7}", size: size)
            }
            if modifiers & UInt32(NSEvent.ModifierFlags.command.rawValue) != 0 {
                Keycap(label: "\u{2318}", size: size)
            }
            Keycap(label: KeyCodeMapping.stringForKeyCode(keyCode), size: size)
        }
    }
}

// MARK: - Reusable Status Badge

struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(Theme.Typography.allCaps(9))
            .tracking(0.5)
            .foregroundColor(color)
            .padding(.horizontal, Theme.Spacing.sm + 2)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }
}
