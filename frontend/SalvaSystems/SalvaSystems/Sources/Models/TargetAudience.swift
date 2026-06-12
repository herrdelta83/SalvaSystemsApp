import Foundation

enum TargetAudience: String, CaseIterable, Identifiable, Codable, Sendable {
    case visualImpairment
    case motorImpairment
    case hearingImpairment
    case neurodivergence
    case elderly
    case cognitiveImpairment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .visualImpairment:   "Visual Impairment"
        case .motorImpairment:    "Motor Impairment"
        case .hearingImpairment:  "Hearing Impairment"
        case .neurodivergence:    "Neurodivergence"
        case .elderly:            "Elderly Users"
        case .cognitiveImpairment: "Cognitive Impairment"
        }
    }

    var icon: String {
        switch self {
        case .visualImpairment:   "eye.slash.fill"
        case .motorImpairment:    "hand.raised.slash.fill"
        case .hearingImpairment:  "ear.trianglebadge.exclamationmark"
        case .neurodivergence:    "brain.fill"
        case .elderly:            "figure.walk"
        case .cognitiveImpairment: "lightbulb.fill"
        }
    }

    var promptContext: String {
        switch self {
        case .visualImpairment:
            "Users who rely on VoiceOver, large text sizes and high contrast. Anything not exposed to the accessibility tree is invisible to them."
        case .motorImpairment:
            "Users with limited fine motor control who depend on large touch targets, Switch Control and a predictable focus order."
        case .hearingImpairment:
            "Users who cannot rely on audio. Information must have a visual or haptic alternative, and text must be clear and readable."
        case .neurodivergence:
            "Users who may be sensitive to motion, animation and visual clutter, and benefit from consistent, predictable layouts."
        case .elderly:
            "Older users who typically need larger text, generous touch targets, strong contrast and reduced motion."
        case .cognitiveImpairment:
            "Users who benefit from simple language, clear labels, low cognitive load and interfaces that avoid relying on memory or speed."
        }
    }

    var criterionWeights: [AccessibilityCriterion: Double] {
        switch self {
        case .visualImpairment:
            [.accessibilityLabels: 1.0, .voiceOverOrder: 1.0, .colorContrast: 0.9,
             .dynamicType: 0.9, .colorIndependence: 0.8, .touchTargetSize: 0.4,
             .reduceMotion: 0.3, .localization: 0.3]
        case .motorImpairment:
            [.touchTargetSize: 1.0, .voiceOverOrder: 0.7, .accessibilityLabels: 0.5,
             .dynamicType: 0.4, .colorContrast: 0.3, .reduceMotion: 0.3,
             .colorIndependence: 0.2, .localization: 0.2]
        case .hearingImpairment:
            [.localization: 0.7, .colorIndependence: 0.6, .dynamicType: 0.6,
             .accessibilityLabels: 0.5, .colorContrast: 0.5, .touchTargetSize: 0.4,
             .voiceOverOrder: 0.3, .reduceMotion: 0.3]
        case .neurodivergence:
            [.reduceMotion: 1.0, .dynamicType: 0.7, .colorContrast: 0.6,
             .colorIndependence: 0.6, .accessibilityLabels: 0.5, .voiceOverOrder: 0.5,
             .touchTargetSize: 0.5, .localization: 0.4]
        case .elderly:
            [.dynamicType: 1.0, .touchTargetSize: 0.9, .colorContrast: 0.9,
             .reduceMotion: 0.6, .accessibilityLabels: 0.6, .colorIndependence: 0.6,
             .voiceOverOrder: 0.5, .localization: 0.4]
        case .cognitiveImpairment:
            [.reduceMotion: 0.8, .dynamicType: 0.8, .accessibilityLabels: 0.7,
             .colorContrast: 0.7, .colorIndependence: 0.7, .voiceOverOrder: 0.6,
             .touchTargetSize: 0.6, .localization: 0.5]
        }
    }
}
