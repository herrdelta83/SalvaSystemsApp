import SwiftUI

extension Color {
    static let afCritical = Color.red
    static let afHigh     = Color.orange
    static let afMedium   = Color(red: 0.95, green: 0.75, blue: 0.0)
    static let afLow      = Color.green
    static let afPrimary  = Color.blue

    static func forSeverity(_ s: Severity) -> Color {
        switch s {
        case .critical: return .afCritical
        case .high:     return .afHigh
        case .medium:   return .afMedium
        case .low:      return .afLow
        }
    }

    static func forDecision(_ d: ReleaseDecision) -> Color {
        switch d {
        case .doNotShip:    return .afCritical
        case .shipWithFixes: return .afHigh
        case .approved:     return .afLow
        }
    }
}
