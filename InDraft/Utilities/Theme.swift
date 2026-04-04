import SwiftUI

enum Theme {
    // MARK: - Colors (from DESIGN.md — "High-End Utilitarian Editorial")

    enum Colors {
        /// Primary background — warm bone canvas
        static let background = Color(hex: "FAF9F6")
        /// Card/container background — lowest surface
        static let cardBackground = Color(hex: "FFFFFF")
        /// Card border — ghost border (outline-variant at 15% opacity)
        static let cardBorder = Color(hex: "AFB3AE").opacity(0.15)
        /// Primary text — charcoal
        static let textPrimary = Color(hex: "2F3430")
        /// Secondary text — on-surface-variant
        static let textSecondary = Color(hex: "5C605C")
        /// Tertiary text — outline
        static let textTertiary = Color(hex: "777C77")
        /// Accent — pale blue for active/selection states
        static let accent = Color(hex: "51616B")
        /// Accent container — pale blue background
        static let accentContainer = Color(hex: "D3E5F0")
        /// Error — warm red
        static let error = Color(hex: "9F403D")
        /// Error container
        static let errorContainer = Color(hex: "FE8983")
        /// Badge background — tertiary-container
        static let badgeBackground = Color(hex: "F4F3F3")
        /// Divider — ghost border
        static let divider = Color(hex: "AFB3AE").opacity(0.15)
        /// Surface container — for layered backgrounds
        static let surfaceContainer = Color(hex: "EDEEEA")
        /// Surface container high — slightly darker
        static let surfaceContainerHigh = Color(hex: "E6E9E4")
        /// Surface container low — lighter than container
        static let surfaceContainerLow = Color(hex: "F4F4F0")
        /// Primary button background
        static let primary = Color(hex: "5A5F62")
        /// On primary — text on primary buttons
        static let onPrimary = Color(hex: "F4F8FC")
        /// Inverse surface — for dark elements
        static let inverseSurface = Color(hex: "0D0F0D")

        // MARK: Semantic Status Colors
        /// Status green — for active, success, connected, granted
        static let statusGreen = Color(hex: "3A7D44")
        /// Status green background
        static let statusGreenBg = Color(hex: "EDF3EC")
        /// Status green text — darker for readability
        static let statusGreenText = Color(hex: "346538")
        /// Status amber — for warnings, untested
        static let statusAmber = Color(hex: "C4930A")
        /// Status amber background
        static let statusAmberBg = Color(hex: "FBF3DB")
        /// Status amber text
        static let statusAmberText = Color(hex: "956400")
        /// Status red — for errors, failures
        static let statusRed = Color(hex: "9F2F2D")
        /// Status red background
        static let statusRedBg = Color(hex: "FDEBEC")
        /// Status blue — for info, connected
        static let statusBlue = Color(hex: "4A7FB5")
        /// Status blue background
        static let statusBlueBg = Color(hex: "4A7FB5").opacity(0.1)

        // MARK: Window Controls — desaturated pastels matching warm editorial palette
        /// Default (inactive) dot — warm gray
        static let windowControlDefault = Color(hex: "C8C8C5")
        /// Close button — muted warm red
        static let windowControlClose = Color(hex: "E8706B")
        /// Minimize button — muted warm amber
        static let windowControlMinimize = Color(hex: "E5BF4B")
        /// Zoom button — muted sage green
        static let windowControlZoom = Color(hex: "6BBF6A")
        /// Icon glyph on hover — dark charcoal for contrast
        static let windowControlIcon = Color(hex: "3A3A38").opacity(0.85)
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
        static let contentMaxWidth: CGFloat = 360
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

// MARK: - Color Hex Extension

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
            .shadow(color: Color(hex: "2F3430").opacity(0.03), radius: 8, y: 2)
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
