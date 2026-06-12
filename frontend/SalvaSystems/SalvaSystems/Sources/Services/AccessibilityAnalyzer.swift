import Foundation
import FoundationModels

actor AccessibilityAnalyzer {

    // MARK: - Availability check

    var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    // MARK: - Analysis

    func analyze(file: GitHubFile, audience: TargetAudience) async throws -> FileEvaluation {
        guard SystemLanguageModel.default.isAvailable else {
            throw AnalyzerError.modelUnavailable
        }

        let instructions = """
        You are an expert iOS accessibility auditor. Your task is to evaluate SwiftUI and UIKit \
        source files strictly against eight accessibility criteria and return structured scores. \
        Target audience context: \(audience.promptContext) \
        Be objective: score 0 for completely missing coverage, 100 for excellent coverage. \
        Provide concrete code evidence and one actionable suggestion per criterion.
        """

        let prompt = buildPrompt(for: file)

        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: prompt, generating: FileEvaluation.self)
        return response.content
    }

    // MARK: - Prompt builder

    private func buildPrompt(for file: GitHubFile) -> String {
        let maxContentLength = 15_000
        let truncated = file.content.count > maxContentLength
        let content = String(file.content.prefix(maxContentLength))

        var prompt = "Evaluate the following Swift file for iOS accessibility:\n\n"
        prompt += "**File:** \(file.fileName)\n"
        if truncated { prompt += "*(file truncated to first 10,000 characters)*\n" }
        prompt += "\n```swift\n\(content)\n```\n\n"
        prompt += "**Criteria to evaluate:**\n\n"

        for criterion in AccessibilityCriterion.allCases {
            prompt += "- **\(criterion.displayName)**: \(criterion.reviewerGuidance)\n"
        }

        return prompt
    }
}

// MARK: - Error

enum AnalyzerError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        "Apple Intelligence is not available on this device. " +
        "Requires iPhone 15 Pro or later with iOS 18.1+ and Apple Intelligence enabled in Settings."
    }
}
