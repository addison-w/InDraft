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
        /// Success — derived from secondary
        static let success = Color(hex: "51616B")
        /// Error — warm red
        static let error = Color(hex: "9F403D")
        /// Error container
        static let errorContainer = Color(hex: "FE8983")
        /// Warning — amber (tertiary)
        static let warning = Color(hex: "5E5F5F")
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
    }

    // MARK: - Typography (Manrope for Display/Headlines, Inter for Body/Labels)

    enum Typography {
        /// Display headline — Manrope (falls back to rounded system)
        static func headline(_ size: CGFloat = 28) -> Font {
            .custom("Manrope", size: size).weight(.medium)
        }

        /// Section title — Manrope, smaller
        static func sectionTitle(_ size: CGFloat = 20) -> Font {
            .custom("Manrope", size: size).weight(.medium)
        }

        /// Body text — Inter (falls back to system default)
        static func body(_ size: CGFloat = 13) -> Font {
            .custom("Inter", size: size)
        }

        /// Label text — Inter, medium weight
        static func label(_ size: CGFloat = 11) -> Font {
            .custom("Inter", size: size).weight(.medium)
        }

        /// Monospaced — SF Mono for keyboard shortcuts
        static func mono(_ size: CGFloat = 11) -> Font {
            .system(size: size, design: .monospaced)
        }

        /// Caption — Inter, small
        static func caption(_ size: CGFloat = 10) -> Font {
            .custom("Inter", size: size)
        }

        /// All caps label — Inter, medium
        static func allCaps(_ size: CGFloat = 10) -> Font {
            .custom("Inter", size: size).weight(.medium)
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
            .shadow(color: Color(hex: "2F3430").opacity(0.04), radius: 12, y: 4)
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

    func badgeStyle(color: Color = Theme.Colors.badgeBackground) -> some View {
        modifier(BadgeStyle(color: color))
    }
}
