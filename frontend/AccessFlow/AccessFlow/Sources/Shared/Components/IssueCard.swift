import SwiftUI

struct IssueCard: View {
    let issue: AccessibilityIssue
    var showChevron: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.forSeverity(issue.severity))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    SeverityBadge(severity: issue.severity, compact: true)
                    Spacer()
                    Text(issue.wcagCriteria)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(issue.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(issue.brokenTask)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    ForEach(issue.affectedProfiles.prefix(3), id: \.self) { profile in
                        Image(systemName: profile.icon)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    if issue.affectedProfiles.count > 3 {
                        Text("+\(issue.affectedProfiles.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(14)
        .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}
