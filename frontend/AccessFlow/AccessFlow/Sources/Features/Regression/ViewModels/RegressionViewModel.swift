import Observation

@Observable
final class RegressionViewModel {
    let comparison: RegressionComparison

    init(comparison: RegressionComparison = MockData.sampleRegression) {
        self.comparison = comparison
    }

    var baseVersion: String    { comparison.baseReport.version }
    var compareVersion: String { comparison.compareReport.version }
    var delta: Int { comparison.newIssues.count - comparison.fixedIssues.count }

    var deltaLabel: String {
        if delta > 0 { return "+\(delta) issues" }
        if delta < 0 { return "\(delta) issues" }
        return "No change"
    }
}
