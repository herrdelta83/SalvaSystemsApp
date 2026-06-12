import SwiftUI

// Wire this up in ContentView.swift:
//   var body: some View { RootView() }

enum AppRoute: Hashable {
    case dashboard(AuditReport)
    case issueDetail(AccessibilityIssue, AuditReport)
    case recommendations(AuditReport)
    case reports(AuditReport)
    case regression
    case guidedAudit
    case auditImport
}

struct RootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .dashboard(let report):
                        DashboardView(report: report, path: $path)
                    case .issueDetail(let issue, let report):
                        IssueDetailView(issue: issue, report: report, path: $path)
                    case .recommendations(let report):
                        RecommendationsView(report: report)
                    case .reports(let report):
                        ReportsView(report: report)
                    case .regression:
                        RegressionView()
                    case .guidedAudit:
                        GuidedAuditView(path: $path)
                    case .auditImport:
                        AuditImportView(path: $path)
                    }
                }
        }
    }
}
