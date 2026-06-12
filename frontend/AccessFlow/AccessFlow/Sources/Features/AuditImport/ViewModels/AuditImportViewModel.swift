import Observation
import UniformTypeIdentifiers

@Observable
final class AuditImportViewModel {
    var isImporting: Bool = false
    var importError: String? = nil
    var importedReport: AuditReport? = nil

    func loadSample() -> AuditReport {
        MockData.sampleReport
    }

    func importFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            importError = "Access denied to the selected file."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        // Stub: real parsing lives in backend/Core/Parsing
        importError = "File parsing not yet connected to AccessFlowCore."
    }
}
