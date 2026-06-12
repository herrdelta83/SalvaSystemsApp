import SwiftUI

struct ReportsView: View {
    let report: AuditReport
    @State private var vm: ReportsViewModel

    init(report: AuditReport) {
        self.report = report
        self._vm = State(initialValue: ReportsViewModel(report: report))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                metaSection
                decisionSection
                allIssuesSection
                exportPlaceholder
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Audit Report")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Meta

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.appName).font(.title2).fontWeight(.bold)
                    Text("Version \(report.version)").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(vm.complianceEstimate)
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color.forDecision(report.decision))
                    Text(vm.formattedDate).font(.caption2).foregroundStyle(.tertiary)
                }
            }

            HStack(spacing: 8) {
                summaryPill("\(report.issues.count)", "total issues",  .primary)
                summaryPill("\(report.blockingIssues.count)", "blocking", .red)
                summaryPill("\(report.issuesWithFix.count)", "have fixes", .green)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func summaryPill(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).fontWeight(.bold).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Decision

    private var decisionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Release Decision", systemImage: report.decision.icon)
                .font(.headline)
                .foregroundStyle(Color.forDecision(report.decision))
            Text(report.decision.rationale)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - All Issues

    private var allIssuesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Issues").font(.headline)

            ForEach(Severity.allCases) { severity in
                let group = report.issues.filter { $0.severity == severity }
                if !group.isEmpty {
                    Text(severity.rawValue)
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color.forSeverity(severity))
                        .padding(.top, 4)

                    ForEach(group) { issue in
                        IssueCard(issue: issue, showChevron: false)
                    }
                }
            }
        }
    }

    // MARK: - Export Placeholder

    private var exportPlaceholder: some View {
        Button {
            // Export coming in v2
        } label: {
            Label("Export PDF Report", systemImage: "square.and.arrow.up")
                .font(.subheadline).fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.tertiary, lineWidth: 1, antialiased: true)
                )
        }
        .disabled(true)
        .overlay(alignment: .topTrailing) {
            Text("Coming soon")
                .font(.caption2).fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 6).padding(.vertical, 3)
                .background(.blue, in: Capsule())
                .offset(x: -8, y: -10)
        }
    }
}
