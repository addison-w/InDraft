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

    // MARK: - Typography (Manrope for Display/Headlines, Inter for Body/Labels)

    enum Typography {
        /// Page title — system serif for editorial warmth
        static func pageTitle(_ size: CGFloat = 24) -> Font {
            .system(size: size, design: .serif).weight(.medium)
        }

        /// Section title — system serif, smaller
        static func sectionTitle(_ size: CGFloat = 18) -> Font {
            .system(size: size, design: .serif).weight(.medium)
        }

        /// Body text — system default for crisp rendering
        static func body(_ size: CGFloat = 13) -> Font {
            .system(size: size)
        }

        /// Label text — medium weight
        static func label(_ size: CGFloat = 11) -> Font {
            .system(size: size).weight(.medium)
        }

        /// Monospaced — SF Mono for keyboard shortcuts
        static func mono(_ size: CGFloat = 11) -> Font {
            .system(size: size, design: .monospaced)
        }

        /// Caption — small
        static func caption(_ size: CGFloat = 10) -> Font {
            .system(size: size)
        }

        /// All caps label — medium weight for tracking
        static func allCaps(_ size: CGFloat = 10) -> Font {
            .system(size: size).weight(.medium)
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
