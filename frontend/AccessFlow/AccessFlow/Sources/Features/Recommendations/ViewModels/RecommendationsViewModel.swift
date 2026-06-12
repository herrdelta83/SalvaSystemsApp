import Observation

@Observable
final class RecommendationsViewModel {
    let report: AuditReport

    init(report: AuditReport) {
        self.report = report
    }

    var issuesWithFix: [AccessibilityIssue] {
        report.issues.filter { $0.fix != nil }
            .sorted { $0.severity.rawValue < $1.severity.rawValue }
    }

    var effortSummary: String {
        let low    = issuesWithFix.filter { $0.fix?.effort == "Low" }.count
        let medium = issuesWithFix.filter { $0.fix?.effort == "Medium" }.count
        let high   = issuesWithFix.filter { $0.fix?.effort == "High" }.count
        return "\(low) quick wins · \(medium) moderate · \(high) complex"
    }
}
