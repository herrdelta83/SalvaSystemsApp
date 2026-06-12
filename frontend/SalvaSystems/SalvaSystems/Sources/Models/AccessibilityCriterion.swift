import Foundation

enum AccessibilityCriterion: String, CaseIterable, Identifiable, Codable, Sendable {
    case accessibilityLabels
    case dynamicType
    case colorContrast
    case touchTargetSize
    case voiceOverOrder
    case reduceMotion
    case localization
    case colorIndependence

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .accessibilityLabels: "Accessibility Labels"
        case .dynamicType:         "Dynamic Type"
        case .colorContrast:       "Color Contrast"
        case .touchTargetSize:     "Touch Target Size"
        case .voiceOverOrder:      "VoiceOver Order"
        case .reduceMotion:        "Reduce Motion"
        case .localization:        "Localization & RTL"
        case .colorIndependence:   "Color Independence"
        }
    }

    var icon: String {
        switch self {
        case .accessibilityLabels: "tag.fill"
        case .dynamicType:         "textformat.size"
        case .colorContrast:       "circle.lefthalf.filled"
        case .touchTargetSize:     "hand.point.up.left.fill"
        case .voiceOverOrder:      "arrow.up.arrow.down"
        case .reduceMotion:        "wind"
        case .localization:        "globe"
        case .colorIndependence:   "paintpalette.fill"
        }
    }

    var reviewerGuidance: String {
        switch self {
        case .accessibilityLabels:
            "Check that interactive elements (Button, Toggle, custom tap gestures, image-only buttons) have .accessibilityLabel and, where useful, .accessibilityHint. Images that convey information need labels; decorative ones should be hidden from VoiceOver."
        case .dynamicType:
            "Check that text uses semantic fonts like .font(.body) or .font(.headline) instead of fixed sizes like .font(.system(size: 14)). Fixed frames around text that would clip at larger sizes also count against this."
        case .colorContrast:
            "Check whether colors are semantic (Color.primary, .secondary, asset catalog colors) or hardcoded (Color(red:green:blue:), hex values, .gray text on light backgrounds). Hardcoded combinations risk failing contrast in dark mode or high-contrast settings."
        case .touchTargetSize:
            "Check that tappable elements reach at least 44x44 points. Look for small fixed frames on Buttons, tiny icons with tap gestures, or padding so small the target shrinks below 44pt."
        case .voiceOverOrder:
            "Check whether the layout produces a sensible VoiceOver reading order, and whether .accessibilityElement(children:), .accessibilitySortPriority or grouping is used where complex layouts (ZStack, overlays, grids) would otherwise read in a confusing order."
        case .reduceMotion:
            "Check whether animations respect @Environment(\\.accessibilityReduceMotion) or use reduced alternatives. Autoplaying, repeating or large parallax animations with no opt-out count against this."
        case .localization:
            "Check whether user-facing strings are localizable (String(localized:), LocalizedStringKey, no concatenated sentences) and whether the layout would survive right-to-left languages (leading/trailing instead of left/right)."
        case .colorIndependence:
            "Check whether any information is conveyed by color alone (red/green status dots, colored borders as the only error indicator). There should always be a second channel: icon, text or shape."
        }
    }
}
