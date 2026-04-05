import SwiftUI
import Hugeicons

/// Centralized icon mapping from semantic names to Hugeicons assets.
/// All icon references in the app should go through this enum.
enum AppIcon {
    // Navigation & UI
    case settings
    case actions
    case providers
    case history

    // Common actions
    case add
    case close
    case search
    case copy
    case dragHandle
    case menu
    case power

    // Chevrons
    case chevronRight
    case chevronDown

    // Visibility
    case eye
    case eyeSlash

    // Status
    case success
    case successCircle
    case error
    case errorCircle
    case warning
    case info

    // Edit
    case edit

    // Privacy
    case shieldKey

    // Connection
    case speedTest

    // History empty state
    case clockRewind

    // Action-specific icons (menu bar dropdown)
    case grammarCheck
    case shorten
    case paraphrase
    case summarize
    case translate
    case textDefault

    // Expanded action icons
    case professional
    case simplify
    case expand
    case email
    case chat
    case code
    case creative
    case formal
    case casual
    case list
    case heading
    case bold
    case hashtag
    case tone
    case magic

    var asset: HugeiconsAsset {
        switch self {
        case .settings:      return Hugeicons.settings01
        case .actions:       return Hugeicons.flash
        case .providers:     return Hugeicons.puzzle
        case .history:       return Hugeicons.clock01
        case .add:           return Hugeicons.add01
        case .close:         return Hugeicons.cancel01
        case .search:        return Hugeicons.search01
        case .copy:          return Hugeicons.copy01
        case .dragHandle:    return Hugeicons.dragDropVertical
        case .menu:          return Hugeicons.moreHorizontal
        case .power:         return Hugeicons.power
        case .chevronRight:  return Hugeicons.arrowRight01
        case .chevronDown:   return Hugeicons.arrowDown01
        case .eye:           return Hugeicons.eye
        case .eyeSlash:      return Hugeicons.viewOff
        case .success:       return Hugeicons.tick01
        case .successCircle: return Hugeicons.checkmarkCircle02
        case .error:         return Hugeicons.cancelCircle
        case .errorCircle:   return Hugeicons.cancelCircle
        case .warning:       return Hugeicons.alertSquare
        case .info:          return Hugeicons.minusSignCircle
        case .edit:          return Hugeicons.quillWrite01
        case .shieldKey:     return Hugeicons.shieldKey
        case .speedTest:     return Hugeicons.dashboardSpeed02
        case .clockRewind:   return Hugeicons.timeHalfPass
        case .grammarCheck:  return Hugeicons.checkmarkCircle02
        case .shorten:       return Hugeicons.arrowShrink02
        case .paraphrase:    return Hugeicons.arrowReloadHorizontal
        case .summarize:     return Hugeicons.doc01
        case .translate:     return Hugeicons.translate
        case .textDefault:   return Hugeicons.textAlignLeft
        case .professional:  return Hugeicons.briefcase01
        case .simplify:      return Hugeicons.baby01
        case .expand:        return Hugeicons.arrowExpand02
        case .email:         return Hugeicons.mail01
        case .chat:          return Hugeicons.bubbleChat
        case .code:          return Hugeicons.sourceCode
        case .creative:      return Hugeicons.paintBrush01
        case .formal:        return Hugeicons.graduationScroll
        case .casual:        return Hugeicons.coffee01
        case .list:          return Hugeicons.taskDaily01
        case .heading:       return Hugeicons.heading01
        case .bold:          return Hugeicons.textBold
        case .hashtag:       return Hugeicons.hashtag
        case .tone:          return Hugeicons.voice
        case .magic:         return Hugeicons.magicWand01
        }
    }

    @MainActor
    func image() -> Image {
        asset.image()
    }

    func nsImage(size: CGFloat = 18) -> NSImage? {
        guard let img = asset.nsImage() else { return nil }
        img.size = NSSize(width: size, height: size)
        return img
    }

    /// Custom app logo loaded from bundled SVG, sized for the menu bar.
    static func logoNSImage(height: CGFloat = 18) -> NSImage? {
        guard let url = Bundle.main.url(forResource: "quill-logo", withExtension: "svg"),
              let image = NSImage(contentsOf: url) else { return nil }
        // Scale proportionally based on original aspect ratio (202:248)
        let aspectRatio = image.size.width / image.size.height
        let width = height * aspectRatio
        image.size = NSSize(width: width, height: height)
        image.isTemplate = true
        return image
    }
}
