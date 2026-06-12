import SwiftUI

struct RecommendationsView: View {
    let report: AuditReport
    @State private var vm: RecommendationsViewModel
    @State private var selectedIssue: AccessibilityIssue?

    init(report: AuditReport) {
        self.report = report
        self._vm = State(initialValue: RecommendationsViewModel(report: report))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryBanner
                    .padding(.horizontal, 20)

                ForEach(vm.issuesWithFix) { issue in
                    fixCard(for: issue)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Recommended Fixes")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Summary

    private var summaryBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(vm.issuesWithFix.count) fixes available")
                    .font(.headline)
                Text(vm.effortSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Fix Card

    private func fixCard(for issue: AccessibilityIssue) -> some View {
        guard let fix = issue.fix else { return AnyView(EmptyView()) }
        let isExpanded = selectedIssue == issue

        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selectedIssue = isExpanded ? nil : issue
                    }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        SeverityBadge(severity: issue.severity, compact: true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fix.title)
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            effortTag(fix.effort)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Divider().padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(fix.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Code block
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Label("SwiftUI", systemImage: "swift")
                                    .font(.caption2).fontWeight(.semibold)
                                    .foregroundStyle(.orange)
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = fix.swiftUICode
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 10)
                            .padding(.bottom, 6)

                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(fix.swiftUICode)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 12)
                            }
                        }
                        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(16)
                }
            }
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        )
    }

    private func effortTag(_ effort: String) -> some View {
        let color: Color = effort == "Low" ? .green : effort == "Medium" ? .orange : .red
        return Text(effort + " effort")
            .font(.caption2)
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}
