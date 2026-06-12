import Observation

@Observable
final class HomeViewModel {
    var isLoadingSample = false

    func loadSampleReport() -> AuditReport {
        MockData.sampleReport
    }
}
