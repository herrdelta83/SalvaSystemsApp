import Observation
import Foundation

@Observable
final class GuidedAuditViewModel {
    var currentStep: Int = 0
    var taskDescription: String = ""
    var selectedProfile: UserProfile? = nil
    var issueDescription: String = ""
    var blocksTask: Bool = false
    var selectedSeverity: Severity = .medium
    var collectedIssues: [AccessibilityIssue] = []

    var totalSteps: Int { 4 }
    var isStepValid: Bool {
        switch currentStep {
        case 0: return !taskDescription.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return selectedProfile != nil
        case 2: return !issueDescription.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    func addCurrentIssue() {
        guard let profile = selectedProfile else { return }
        let issue = AccessibilityIssue(
            title: issueDescription,
            description: issueDescription,
            brokenTask: taskDescription,
            affectedProfiles: [profile],
            severity: selectedSeverity,
            wcagCriteria: "Pending analysis",
            impact: blocksTask ? "Blocks the user flow entirely." : "Degrades the user experience."
        )
        collectedIssues.append(issue)
    }

    func generateReport() -> AuditReport {
        let decision: ReleaseDecision = collectedIssues.contains { $0.severity == .critical }
            ? .doNotShip : collectedIssues.contains { $0.severity == .high }
            ? .shipWithFixes : .approved
        return AuditReport(
            appName: "Guided Audit",
            version: "1.0.0",
            issues: collectedIssues,
            decision: decision
        )
    }

    func reset() {
        currentStep = 0
        taskDescription = ""
        selectedProfile = nil
        issueDescription = ""
        blocksTask = false
        selectedSeverity = .medium
    }
}
