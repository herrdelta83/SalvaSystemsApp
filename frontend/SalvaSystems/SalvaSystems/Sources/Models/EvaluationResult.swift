import Foundation
import FoundationModels

// MARK: - Model output (per file)

@Generable
struct CriterionFinding: Equatable, Sendable {
    @Guide(description: "Score from 0 (completely inaccessible) to 100 (excellent)", .range(0...100))
    var score: Int

    @Guide(description: "The single most relevant line of code as evidence, or 'no evidence found' if the criterion does not apply to this file")
    var evidence: String

    @Guide(description: "One short, actionable suggestion in English. If the criterion is already well covered, acknowledge it briefly.")
    var suggestion: String
}

@Generable
struct FileEvaluation: Equatable, Sendable {
    @Guide(description: "accessibilityLabel and accessibilityHint on interactive elements")
    var accessibilityLabels: CriterionFinding

    @Guide(description: "Semantic fonts and Dynamic Type support vs fixed font sizes")
    var dynamicType: CriterionFinding

    @Guide(description: "Semantic colors vs hardcoded colors that may fail contrast")
    var colorContrast: CriterionFinding

    @Guide(description: "Interactive elements reaching the 44x44pt minimum touch target")
    var touchTargetSize: CriterionFinding

    @Guide(description: "VoiceOver reading order, accessibility grouping and sort priority")
    var voiceOverOrder: CriterionFinding

    @Guide(description: "Animations respecting the Reduce Motion accessibility setting")
    var reduceMotion: CriterionFinding

    @Guide(description: "Localizable strings and right-to-left layout support")
    var localization: CriterionFinding

    @Guide(description: "Information conveyed by color having a non-color alternative")
    var colorIndependence: CriterionFinding
}

extension FileEvaluation {
    subscript(criterion: AccessibilityCriterion) -> CriterionFinding {
        switch criterion {
        case .accessibilityLabels: accessibilityLabels
        case .dynamicType:         dynamicType
        case .colorContrast:       colorContrast
        case .touchTargetSize:     touchTargetSize
        case .voiceOverOrder:      voiceOverOrder
        case .reduceMotion:        reduceMotion
        case .localization:        localization
        case .colorIndependence:   colorIndependence
        }
    }
}

// MARK: - Per-file record

struct FileEvaluationRecord: Identifiable, Equatable, Sendable {
    let path: String
    let evaluation: FileEvaluation

    var id: String { path }

    var fileName: String {
        path.split(separator: "/").last.map(String.init) ?? path
    }

    var averageScore: Double {
        let scores = AccessibilityCriterion.allCases.map { Double(evaluation[$0].score) }
        return scores.reduce(0, +) / Double(scores.count)
    }
}

// MARK: - Aggregated report

struct EvaluationReport: Equatable, Sendable {
    let repositoryName: String
    let audience: TargetAudience
    let records: [FileEvaluationRecord]
    let criterionAverages: [AccessibilityCriterion: Double]
    let globalScore: Double

    init(repositoryName: String, audience: TargetAudience, records: [FileEvaluationRecord]) {
        self.repositoryName = repositoryName
        self.audience = audience
        self.records = records

        var averages: [AccessibilityCriterion: Double] = [:]
        for criterion in AccessibilityCriterion.allCases {
            let scores = records.map { Double($0.evaluation[criterion].score) }
            averages[criterion] = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        }
        self.criterionAverages = averages

        let weights = audience.criterionWeights
        let totalWeight = weights.values.reduce(0, +)
        guard totalWeight > 0, !records.isEmpty else {
            self.globalScore = 0
            return
        }
        let weightedSum = AccessibilityCriterion.allCases.reduce(0.0) { partial, criterion in
            partial + (averages[criterion] ?? 0) * (weights[criterion] ?? 0)
        }
        self.globalScore = weightedSum / totalWeight
    }

    var prioritizedCriteria: [AccessibilityCriterion] {
        let weights = audience.criterionWeights
        return AccessibilityCriterion.allCases.sorted { a, b in
            let impactA = (100 - (criterionAverages[a] ?? 0)) * (weights[a] ?? 0)
            let impactB = (100 - (criterionAverages[b] ?? 0)) * (weights[b] ?? 0)
            return impactA > impactB
        }
    }

    func suggestions(for criterion: AccessibilityCriterion, limit: Int = 3) -> [String] {
        records
            .map { $0.evaluation[criterion] }
            .filter { $0.score < 80 }
            .sorted { $0.score < $1.score }
            .prefix(limit)
            .map(\.suggestion)
    }
}
