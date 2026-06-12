import SwiftUI

struct DashboardView: View {
    let report: AuditReport
    @Binding var path: NavigationPath
    @State private var vm: DashboardViewModel

    init(report: AuditReport, path: Binding<NavigationPath>) {
        self.report = report
        self._path = path
        self._vm = State(initialValue: DashboardViewModel(report: report))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                decisionBanner
                statsRow
                blockingSection
                profilesSection
                actionButtons
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("\(report.appName) \(report.version)")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Decision Banner

    private var decisionBanner: some View {
        let color = Color.forDecision(report.decision)
        return HStack(spacing: 14) {
            Image(systemName: report.decision.icon)
                .font(.system(size: 32))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 4) {
                Text("Release Decision")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(report.decision.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            Spacer()
        }
        .padding(18)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statChip(count: report.criticalIssues.count, severity: .critical)
            statChip(count: report.highIssues.count,     severity: .high)
            statChip(count: report.mediumIssues.count,   severity: .medium)
            statChip(count: report.lowIssues.count,      severity: .low)
        }
    }

    private func statChip(count: Int, severity: Severity) -> some View {
        let color = Color.forSeverity(severity)
        return VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(count > 0 ? color : .secondary)
            Text(severity.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(count > 0 ? color.opacity(0.08) : Color(.tertiarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Blocking Issues

    private var blockingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Blocking Issues", systemImage: "exclamationmark.shield")
                    .font(.headline)
                Spacer()
                Text("\(report.blockingIssues.count) issues")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if report.blockingIssues.isEmpty {
                Label("No blocking issues found", systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(report.blockingIssues) { issue in
                    Button {
                        path.append(AppRoute.issueDetail(issue, report))
                    } label: {
                        IssueCard(issue: issue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Affected Profiles

    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Affected User Profiles", systemImage: "person.3")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(report.affectedProfilesDistinct) { profile in
                    Label(profile.rawValue, systemImage: profile.icon)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.secondarySystemBackground, in: Capsule())
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                path.append(AppRoute.reports(report))
            } label: {
                Label("Full Report", systemImage: "doc.text")
                    .font(.subheadline).fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 10) {
                Button {
                    path.append(AppRoute.recommendations(report))
                } label: {
                    Label("Fixes", systemImage: "wrench.and.screwdriver")
                        .font(.subheadline).fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    path.append(AppRoute.regression)
                } label: {
                    Label("Regression", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline).fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Flow Layout helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0, +)
            + CGFloat(max(rows.count - 1, 0)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in computeRows(proposal: proposal, subviews: subviews) {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        for view in subviews {
            let w = view.sizeThatFits(.unspecified).width
            if rowWidth + w > maxWidth && !rows[rows.endIndex - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.endIndex - 1].append(view)
            rowWidth += w + spacing
        }
        return rows
    }
}
