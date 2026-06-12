import Foundation

// MARK: - Severity

enum Severity: String, CaseIterable, Identifiable, Hashable {
    case critical = "Critical"
    case high     = "High"
    case medium   = "Medium"
    case low      = "Low"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .critical: return "xmark.circle.fill"
        case .high:     return "exclamationmark.circle.fill"
        case .medium:   return "exclamationmark.triangle.fill"
        case .low:      return "info.circle.fill"
        }
    }
}

// MARK: - User Profile

enum UserProfile: String, CaseIterable, Identifiable, Hashable {
    case visualImpairment = "Visual Impairment"
    case motorImpairment  = "Motor Impairment"
    case cognitive        = "Cognitive Disability"
    case colorBlindness   = "Color Blindness"
    case deaf             = "Deaf / Hard of Hearing"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .visualImpairment: return "eye.slash"
        case .motorImpairment:  return "hand.raised.slash"
        case .cognitive:        return "brain.head.profile"
        case .colorBlindness:   return "paintpalette"
        case .deaf:             return "ear.slash"
        }
    }
}

// MARK: - Release Decision

enum ReleaseDecision: String, Hashable {
    case doNotShip    = "Do Not Ship"
    case shipWithFixes = "Ship with Fixes"
    case approved     = "Approved to Ship"

    var icon: String {
        switch self {
        case .doNotShip:    return "xmark.shield.fill"
        case .shipWithFixes: return "exclamationmark.shield.fill"
        case .approved:     return "checkmark.shield.fill"
        }
    }

    var rationale: String {
        switch self {
        case .doNotShip:
            return "This build contains critical accessibility failures that block core tasks for users with disabilities. Shipping would violate WCAG 2.1 AA compliance."
        case .shipWithFixes:
            return "No blocking issues found. High-severity issues should be resolved in a follow-up sprint before next major release."
        case .approved:
            return "All accessibility checks passed. This build meets WCAG 2.1 AA requirements."
        }
    }
}

// MARK: - Code Fix

struct CodeFix: Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let swiftUICode: String
    let effort: String

    init(title: String, summary: String, swiftUICode: String, effort: String) {
        self.id = UUID()
        self.title = title
        self.summary = summary
        self.swiftUICode = swiftUICode
        self.effort = effort
    }
}

// MARK: - Accessibility Issue

struct AccessibilityIssue: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let brokenTask: String
    let affectedProfiles: [UserProfile]
    let severity: Severity
    let wcagCriteria: String
    let impact: String
    let fix: CodeFix?

    init(title: String, description: String, brokenTask: String,
         affectedProfiles: [UserProfile], severity: Severity,
         wcagCriteria: String, impact: String, fix: CodeFix? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.brokenTask = brokenTask
        self.affectedProfiles = affectedProfiles
        self.severity = severity
        self.wcagCriteria = wcagCriteria
        self.impact = impact
        self.fix = fix
    }

    static func == (lhs: AccessibilityIssue, rhs: AccessibilityIssue) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Audit Report

struct AuditReport: Identifiable, Hashable {
    let id: UUID
    let appName: String
    let version: String
    let auditDate: Date
    let issues: [AccessibilityIssue]
    let decision: ReleaseDecision

    init(appName: String, version: String, auditDate: Date = .now,
         issues: [AccessibilityIssue], decision: ReleaseDecision) {
        self.id = UUID()
        self.appName = appName
        self.version = version
        self.auditDate = auditDate
        self.issues = issues
        self.decision = decision
    }

    var criticalIssues: [AccessibilityIssue] { issues.filter { $0.severity == .critical } }
    var highIssues: [AccessibilityIssue]     { issues.filter { $0.severity == .high } }
    var mediumIssues: [AccessibilityIssue]   { issues.filter { $0.severity == .medium } }
    var lowIssues: [AccessibilityIssue]      { issues.filter { $0.severity == .low } }
    var blockingIssues: [AccessibilityIssue] { issues.filter { $0.severity == .critical || $0.severity == .high } }
    var issuesWithFix: [AccessibilityIssue]  { issues.filter { $0.fix != nil } }

    var affectedProfilesDistinct: [UserProfile] {
        Array(Set(issues.flatMap { $0.affectedProfiles })).sorted { $0.rawValue < $1.rawValue }
    }

    static func == (lhs: AuditReport, rhs: AuditReport) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Regression

struct RegressionComparison {
    let baseReport: AuditReport
    let compareReport: AuditReport
    let newIssues: [AccessibilityIssue]
    let fixedIssues: [AccessibilityIssue]
    let worsenedIssues: [AccessibilityIssue]
}

// MARK: - Mock Data

enum MockData {

    static let sampleReport = AuditReport(
        appName: "HealthConnect",
        version: "1.1.0",
        issues: issues_v1_1,
        decision: .doNotShip
    )

    static let previousReport = AuditReport(
        appName: "HealthConnect",
        version: "1.0.0",
        auditDate: Calendar.current.date(byAdding: .day, value: -14, to: .now) ?? .now,
        issues: issues_v1_0,
        decision: .doNotShip
    )

    static let sampleRegression = RegressionComparison(
        baseReport: previousReport,
        compareReport: sampleReport,
        newIssues: [issues_v1_1[3], issues_v1_1[7]],
        fixedIssues: [
            AccessibilityIssue(
                title: "Settings button missing label",
                description: "Settings gear icon had no accessibility label in v1.0.",
                brokenTask: "Cannot navigate to settings via VoiceOver",
                affectedProfiles: [.visualImpairment],
                severity: .high,
                wcagCriteria: "WCAG 2.1 AA 1.1.1",
                impact: "VoiceOver users could not access the settings screen."
            ),
            AccessibilityIssue(
                title: "Back button unlabeled",
                description: "The custom back chevron was announced as 'image' by VoiceOver.",
                brokenTask: "Cannot navigate back using VoiceOver",
                affectedProfiles: [.visualImpairment],
                severity: .medium,
                wcagCriteria: "WCAG 2.1 AA 1.1.1",
                impact: "Users were trapped on detail screens without sighted help."
            )
        ],
        worsenedIssues: []
    )

    // MARK: v1.1.0 Issues

    static let issues_v1_1: [AccessibilityIssue] = [

        AccessibilityIssue(
            title: "Emergency button has no accessibility label",
            description: "The 'Emergency Contact' button uses only a phone icon with no .accessibilityLabel. VoiceOver reads it as 'phone.fill image'.",
            brokenTask: "Cannot call emergency contact using VoiceOver",
            affectedProfiles: [.visualImpairment],
            severity: .critical,
            wcagCriteria: "WCAG 2.1 AA 1.1.1",
            impact: "A blind user in a medical emergency cannot trigger the emergency call without sighted help — a direct safety risk.",
            fix: CodeFix(
                title: "Add .accessibilityLabel to the emergency button",
                summary: "Label the button so VoiceOver announces its purpose and action clearly.",
                swiftUICode: """
Button(action: callEmergency) {
    Image(systemName: "phone.fill")
}
.accessibilityLabel("Call emergency contact")
.accessibilityHint("Calls your primary emergency contact immediately")
""",
                effort: "Low"
            )
        ),

        AccessibilityIssue(
            title: "Medication dosage text: 2.1:1 contrast ratio",
            description: "Critical dosage information uses #8A8A8A on #FFFFFF — a 2.1:1 ratio. WCAG AA requires minimum 4.5:1 for normal text.",
            brokenTask: "Cannot read medication dosage amount",
            affectedProfiles: [.visualImpairment, .colorBlindness],
            severity: .critical,
            wcagCriteria: "WCAG 2.1 AA 1.4.3",
            impact: "Users with low vision cannot read dosage amounts, risking incorrect medication intake. Affects ~8% of the user base.",
            fix: CodeFix(
                title: "Change text color to #595959 (7:1 ratio)",
                summary: "Replace the low-contrast gray with a darker alternative that passes WCAG AAA.",
                swiftUICode: """
Text(medication.dosage)
    .foregroundStyle(Color(hex: "#595959")) // 7.0:1 — passes AAA
    .font(.body)
""",
                effort: "Low"
            )
        ),

        AccessibilityIssue(
            title: "Take Medication button: 24×24pt touch target",
            description: "The primary action button is 24×24pt — well below Apple's 44×44pt minimum. Confirmed with Xcode Accessibility Inspector.",
            brokenTask: "Cannot reliably tap 'Take Medication'",
            affectedProfiles: [.motorImpairment],
            severity: .high,
            wcagCriteria: "WCAG 2.1 AA 2.5.5",
            impact: "Users with motor tremors miss the target 60%+ of the time, leading to skipped doses.",
            fix: CodeFix(
                title: "Expand touch target to 44×44pt minimum",
                summary: "Use .frame(minWidth:minHeight:) or contentShape to grow the interactive area without changing the visual size.",
                swiftUICode: """
Button(action: takeMedication) {
    Label("Take Now", systemImage: "checkmark.circle")
        .padding(.horizontal, 16)
}
.frame(minHeight: 44)
.contentShape(Rectangle())
""",
                effort: "Low"
            )
        ),

        AccessibilityIssue(
            title: "Appointment form: five unlabeled text fields",
            description: "All form fields rely solely on placeholder text. Once focused, placeholder disappears — VoiceOver users lose all context.",
            brokenTask: "Cannot independently fill the appointment booking form",
            affectedProfiles: [.visualImpairment],
            severity: .high,
            wcagCriteria: "WCAG 2.1 AA 1.3.1",
            impact: "VoiceOver users cannot complete appointment booking — a core app flow is fully blocked.",
            fix: CodeFix(
                title: "Add persistent labels above each text field",
                summary: "Pair every TextField with a visible Text label and .accessibilityLabel for VoiceOver.",
                swiftUICode: """
VStack(alignment: .leading, spacing: 4) {
    Text("Full Name").font(.caption).foregroundStyle(.secondary)
    TextField("Full Name", text: $name)
        .accessibilityLabel("Full Name")
        .textFieldStyle(.roundedBorder)
}
""",
                effort: "Medium"
            )
        ),

        AccessibilityIssue(
            title: "Health metrics chart is entirely inaccessible",
            description: "The blood pressure trend chart has no title, axis labels, or data descriptions. VoiceOver skips it entirely.",
            brokenTask: "Cannot access own health trend data",
            affectedProfiles: [.visualImpairment],
            severity: .high,
            wcagCriteria: "WCAG 2.1 AA 1.1.1",
            impact: "Blind users cannot track health metrics — the primary purpose of the app — without sighted assistance.",
            fix: CodeFix(
                title: "Implement AXChartDescriptorRepresentable",
                summary: "Add an audio graph descriptor so VoiceOver can read chart data point by point.",
                swiftUICode: """
Chart(healthData) { point in
    LineMark(
        x: .value("Date", point.date),
        y: .value("Systolic BP", point.systolic)
    )
}
.accessibilityChartDescriptor(BPChartDescriptor(data: healthData))
""",
                effort: "High"
            )
        ),

        AccessibilityIssue(
            title: "All body text ignores Dynamic Type",
            description: "Body text uses .font(.system(size: 13)) throughout, ignoring the user's preferred text size from iOS Settings.",
            brokenTask: "Cannot read content at preferred accessibility text size",
            affectedProfiles: [.visualImpairment],
            severity: .medium,
            wcagCriteria: "WCAG 2.1 AA 1.4.4",
            impact: "10% of iOS users have text size set above default. All body content is unreadable at their preferred size.",
            fix: CodeFix(
                title: "Replace fixed sizes with semantic font styles",
                summary: "SwiftUI's built-in font styles automatically scale with Dynamic Type — no extra code needed.",
                swiftUICode: """
// Before (fails):
Text(content).font(.system(size: 13))

// After (passes):
Text(content).font(.body)       // scales automatically
Text(title).font(.headline)     // scales automatically
""",
                effort: "Medium"
            )
        ),

        AccessibilityIssue(
            title: "Emergency actions provide no haptic feedback",
            description: "Critical confirmations and error states provide no haptic or audio cue, relying solely on visual alerts.",
            brokenTask: "Cannot confirm whether emergency call was triggered",
            affectedProfiles: [.deaf, .visualImpairment],
            severity: .medium,
            wcagCriteria: "WCAG 2.1 AA 1.3.3",
            impact: "Deaf users and eyes-free users cannot confirm if a critical action completed successfully.",
            fix: CodeFix(
                title: "Add UINotificationFeedbackGenerator on critical actions",
                summary: "Trigger haptic feedback on emergency confirmation and error states.",
                swiftUICode: """
Button("Call Emergency") {
    UINotificationFeedbackGenerator()
        .notificationOccurred(.success)
    callEmergency()
}
""",
                effort: "Low"
            )
        ),

        AccessibilityIssue(
            title: "Settings: no skip navigation for 34 header items",
            description: "The settings screen header contains 34 interactive elements before reaching the main content. No grouping or skip link exists.",
            brokenTask: "Cannot quickly navigate to primary settings content",
            affectedProfiles: [.motorImpairment, .cognitive],
            severity: .medium,
            wcagCriteria: "WCAG 2.1 AA 2.4.1",
            impact: "Switch control users must traverse 34 elements before reaching any useful setting. Estimated 4-minute interaction cost.",
            fix: CodeFix(
                title: "Group header with .accessibilityElement(children: .contain)",
                summary: "Bundle the navigation header as a single focusable unit to reduce the number of stops.",
                swiftUICode: """
HStack { /* navigation items */ }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Navigation header")
""",
                effort: "Medium"
            )
        ),

        AccessibilityIssue(
            title: "Three identical 'Read more' links",
            description: "Three article cards each have a 'Read more' button. VoiceOver's Link rotor lists three identical labels with no context.",
            brokenTask: "Cannot distinguish which article each 'Read more' opens",
            affectedProfiles: [.cognitive, .visualImpairment],
            severity: .low,
            wcagCriteria: "WCAG 2.1 AA 2.4.6",
            impact: "Screen reader users must listen to surrounding article text to determine which link to activate.",
            fix: CodeFix(
                title: "Override link label with article title",
                summary: "Use .accessibilityLabel to give each link unique, descriptive text for the accessibility tree.",
                swiftUICode: """
Button("Read more") { open(article) }
    .accessibilityLabel("Read more about \\(article.title)")
""",
                effort: "Low"
            )
        ),

        AccessibilityIssue(
            title: "Decorative avatars announced by VoiceOver",
            description: "Contact list avatar thumbnails are announced as 'image' by VoiceOver, cluttering navigation with irrelevant stops.",
            brokenTask: "Navigating contacts list is slow and noisy with VoiceOver",
            affectedProfiles: [.visualImpairment],
            severity: .low,
            wcagCriteria: "WCAG 2.1 AA 1.1.1",
            impact: "Each avatar adds an unnecessary focus stop, increasing navigation time by ~15% per contact.",
            fix: CodeFix(
                title: "Mark decorative images with .accessibilityHidden(true)",
                summary: "Remove purely decorative images from the accessibility tree.",
                swiftUICode: """
AsyncImage(url: contact.avatarURL) { image in
    image.resizable()
} placeholder: { Circle().fill(.quaternary) }
.accessibilityHidden(true)
""",
                effort: "Low"
            )
        )
    ]

    // MARK: v1.0.0 Issues (subset — 3 fewer issues than v1.1)

    static let issues_v1_0: [AccessibilityIssue] = Array(issues_v1_1.prefix(7)) + [
        AccessibilityIssue(
            title: "Settings button missing accessibility label",
            description: "Settings gear icon had no accessibility label in v1.0.",
            brokenTask: "Cannot navigate to settings via VoiceOver",
            affectedProfiles: [.visualImpairment],
            severity: .high,
            wcagCriteria: "WCAG 2.1 AA 1.1.1",
            impact: "VoiceOver users could not access the settings screen."
        ),
        AccessibilityIssue(
            title: "Back button unlabeled in navigation",
            description: "Custom back chevron was announced as 'image' by VoiceOver.",
            brokenTask: "Cannot navigate back using VoiceOver",
            affectedProfiles: [.visualImpairment],
            severity: .medium,
            wcagCriteria: "WCAG 2.1 AA 1.1.1",
            impact: "Users were trapped on detail screens without sighted assistance."
        )
    ]
}
