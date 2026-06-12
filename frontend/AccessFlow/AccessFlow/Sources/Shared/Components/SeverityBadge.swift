import SwiftUI

struct SeverityBadge: View {
    let severity: Severity
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.icon)
            if !compact {
                Text(severity.rawValue).fontWeight(.semibold)
            }
        }
        .font(compact ? .caption2 : .caption)
        .foregroundStyle(.white)
        .padding(.horizontal, compact ? 7 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(Color.forSeverity(severity), in: Capsule())
    }
}
