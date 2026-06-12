import SwiftUI

struct IssueDetailView: View {
    let issue: AccessibilityIssue
    let report: AuditReport
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                humanTaskSection
                profilesSection
                impactSection
                wcagSection
                if issue.fix != nil { fixButton }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Issue Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SeverityBadge(severity: issue.severity)

            Text(issue.title)
                .font(.title3)
                .fontWeight(.bold)

            Text(issue.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Human Task

    private var humanTaskSection: some View {
        infoCard(
            icon: "person.fill.xmark",
            iconColor: .red,
            title: "What human task breaks?",
            content: issue.brokenTask
        )
    }

    // MARK: - Profiles

    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Who is affected?", systemImage: "person.3.fill")
                .font(.subheadline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                ForEach(issue.affectedProfiles) { profile in
                    HStack(spacing: 12) {
                        Image(systemName: profile.icon)
                            .font(.body)
                            .foregroundStyle(.blue)
                            .frame(width: 24)
                        Text(profile.rawValue)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // MARK: - Impact

    private var impactSection: some View {
        infoCard(
            icon: "exclamationmark.bubble.fill",
            iconColor: .orange,
            title: "Why it matters",
            content: issue.impact
        )
    }

    // MARK: - WCAG

    private var wcagSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("WCAG Criteria").font(.caption).foregroundStyle(.secondary)
                Text(issue.wcagCriteria).font(.subheadline).fontWeight(.medium)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Fix Button

    private var fixButton: some View {
        Button {
            path.append(AppRoute.recommendations(report))
        } label: {
            Label("See Recommended Fix", systemImage: "wrench.and.screwdriver.fill")
                .font(.subheadline).fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Helper

    private func infoCard(icon: String, iconColor: Color, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(iconColor)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
