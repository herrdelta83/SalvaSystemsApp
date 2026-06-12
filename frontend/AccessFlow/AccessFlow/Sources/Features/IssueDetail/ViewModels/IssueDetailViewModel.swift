import Observation

@Observable
final class IssueDetailViewModel {
    let issue: AccessibilityIssue
    let report: AuditReport

    init(issue: AccessibilityIssue, report: AuditReport) {
        self.issue = issue
        self.report = report
    }
}
