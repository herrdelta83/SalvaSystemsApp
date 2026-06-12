import SwiftUI

struct RegressionView: View {
    @State private var vm = RegressionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                versionHeader
                    .padding(.horizontal, 20)

                if !vm.comparison.newIssues.isEmpty {
                    issueGroup(
                        title: "New Issues",
                        icon: "plus.circle.fill",
                        color: .red,
                        issues: vm.comparison.newIssues
                    )
                }

                if !vm.comparison.fixedIssues.isEmpty {
                    issueGroup(
                        title: "Fixed Issues",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        issues: vm.comparison.fixedIssues
                    )
                }

                if !vm.comparison.worsenedIssues.isEmpty {
                    issueGroup(
                        title: "Worsened Issues",
                        icon: "arrow.up.circle.fill",
                        color: .orange,
                        issues: vm.comparison.worsenedIssues
                    )
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Regression Analysis")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Version Header

    private var versionHeader: some View {
        HStack(spacing: 0) {
            versionChip(vm.baseVersion, label: "Base", color: .secondary)

            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)

            versionChip(vm.compareVersion, label: "Compare", color: .blue)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(vm.deltaLabel)
                    .font(.headline)
                    .foregroundStyle(vm.delta > 0 ? .red : vm.delta < 0 ? .green : .secondary)
                Text("net change").font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func versionChip(_ version: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("v\(version)").font(.headline).fontWeight(.semibold).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: - Issue Group

    private func issueGroup(title: String, icon: String, color: Color,
                            issues: [AccessibilityIssue]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)
                .padding(.horizontal, 20)

            ForEach(issues) { issue in
                IssueCard(issue: issue, showChevron: false)
                    .padding(.horizontal, 20)
            }
        }
    }
}
