import Observation

@Observable
final class ReportsViewModel {
    let report: AuditReport

    init(report: AuditReport) {
        self.report = report
    }

    var formattedDate: String {
        report.auditDate.formatted(date: .long, time: .shortened)
    }

    var scoreLabel: String {
        let blocking = report.blockingIssues.count
        let total    = report.issues.count
        if blocking == 0 { return "Pass" }
        return "\(blocking)/\(total) blocking"
    }

    var complianceEstimate: String {
        let c = report.criticalIssues.count
        let h = report.highIssues.count
        if c == 0 && h == 0 { return "WCAG 2.1 AA Compliant" }
        if c == 0           { return "Partially Compliant" }
        return "Non-Compliant"
    }
}
