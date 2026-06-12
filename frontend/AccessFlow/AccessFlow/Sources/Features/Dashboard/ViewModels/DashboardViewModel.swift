import Observation

@Observable
final class DashboardViewModel {
    let report: AuditReport

    init(report: AuditReport) {
        self.report = report
    }
}
