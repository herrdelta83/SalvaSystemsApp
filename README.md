# AccessFlow

iOS app that audits any public or private GitHub Swift repository for accessibility issues using the GitHub REST API and Apple Intelligence (FoundationModels) entirely on-device.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Tech Stack](#tech-stack)
- [Repository Layout](#repository-layout)
- [Analysis Pipeline](#analysis-pipeline)
  - [Stage 1 — Repository Fetch](#stage-1--repository-fetch)
  - [Stage 2 — File Filter](#stage-2--file-filter)
  - [Stage 3 — On-Device AI Analysis](#stage-3--on-device-ai-analysis)
  - [Stage 4 — Report Generation](#stage-4--report-generation)
- [Accessibility Criteria](#accessibility-criteria)
- [Scoring System](#scoring-system)
- [Target Audiences](#target-audiences)
- [Limits & Configuration](#limits--configuration)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Simulator](#simulator)
  - [Physical iPhone](#physical-iphone)
- [Contributing](#contributing)

---

## Architecture Overview

AccessFlow is a fully native iOS app. There is no server, no cloud inference, and no external AI API. Everything runs on the device.

| Component | Technology | Responsibility |
|-----------|------------|----------------|
| **UI** | SwiftUI · `@Observable` MVVM | Three-screen flow: input → progress → report |
| **GitHub layer** | GitHub REST API v3 | Fetch repo tree and decode file blobs |
| **AI layer** | Apple FoundationModels (`LanguageModelSession`) | Structured on-device evaluation of each Swift file |
| **Keychain** | Security framework (`SecItem`) | Secure storage of the GitHub Personal Access Token |

### App Flow

```
User enters GitHub URL + selects target audience
                │
                ▼
      EvaluationViewModel.startEvaluation()
                │
    ┌───────────▼────────────┐
    │   Stage 1: Fetch repo  │  GET /repos/{owner}/{repo}
    │   → default branch     │  GET /repos/.../git/trees/{branch}?recursive=1
    └───────────┬────────────┘
                │  [GitHubTreeResponse.Entry]
    ┌───────────▼────────────┐
    │   Stage 2: Filter      │  .swift, ≤ 60 KB, not tests/Pods/generated
    │   → UI files only      │  containsUICode → View + body || UIViewController
    └───────────┬────────────┘
                │  [GitHubFile]
    ┌───────────▼────────────┐
    │   Stage 3: AI analyze  │  LanguageModelSession per file
    │   → FileEvaluation     │  Structured generation via @Generable
    └───────────┬────────────┘
                │  [FileEvaluationRecord]
    ┌───────────▼────────────┐
    │   Stage 4: Report      │  Weighted scores per criterion + global score
    └───────────┬────────────┘
                │
                ▼
           ReportView
```

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Language** | Swift 5.9 |
| **UI framework** | SwiftUI |
| **State management** | `@Observable` (Observation framework, iOS 17+) |
| **AI inference** | Apple FoundationModels — `LanguageModelSession`, `@Generable`, `@Guide` |
| **Networking** | Foundation `URLSession` (async/await) |
| **Secure storage** | Security framework — `SecItemAdd` / `SecItemCopyMatching` |
| **Project generation** | XcodeGen 2.42.0 |
| **Minimum OS** | iOS 26.0 |
| **Recommended device** | iPhone 15 Pro or newer (Apple Intelligence required for AI stage) |

---

## Repository Layout

```
.
├── frontend/
│   └── SalvaSystems/                          # XcodeGen workspace — produces AccessFlow.xcodeproj
│       ├── project.yml                        # XcodeGen spec (iOS 26, MVVM sources, AccessFlow target)
│       └── SalvaSystems/
│           ├── Assets.xcassets/
│           └── Sources/
│               ├── App/
│               │   └── SalvaSystemsApp.swift  # @main AccessFlowApp — state-driven root navigation
│               ├── Models/
│               │   ├── AccessibilityCriterion.swift  # 8-case enum: displayName, icon, reviewerGuidance
│               │   ├── EvaluationResult.swift         # @Generable structs + FileEvaluationRecord + EvaluationReport
│               │   ├── GitHubFile.swift               # Decoded blob + containsUICode heuristic
│               │   ├── GitHubTreeResponse.swift       # Tree + Entry + swiftFileCandidates() filter
│               │   └── TargetAudience.swift           # 6-case enum: promptContext + criterionWeights
│               ├── Services/
│               │   ├── AccessibilityAnalyzer.swift    # actor — LanguageModelSession, prompt builder
│               │   ├── GitHubService.swift            # actor — REST client (branch, tree, blob)
│               │   └── KeychainHelper.swift           # enum — save / retrieve / delete PAT
│               ├── ViewModels/
│               │   └── EvaluationViewModel.swift      # @Observable @MainActor orchestrator
│               └── Views/
│                   ├── RepoInputView.swift            # URL field, audience picker, optional token
│                   ├── EvaluationProgressView.swift   # Animated progress — loading / analyzing states
│                   └── ReportView.swift               # Score ring, criteria grid, suggestions, file list
├── backend/
│   └── Core/                                 # Reserved for future Swift Package / server-side tooling
│       ├── Explanations/
│       ├── FeatureExtraction/
│       ├── ML/
│       ├── Models/
│       ├── Parsing/
│       ├── Recommendations/
│       ├── Regression/
│       ├── Reports/
│       ├── RuleEngine/
│       └── SeverityScoring/
├── scripts/
│   └── mac-setup.sh                          # One-shot Mac setup: XcodeGen install + project generation
└── .githooks/
    └── post-merge                            # Auto-runs mac-setup.sh on git pull
```

---

## Analysis Pipeline

### Stage 1 — Repository Fetch

`GitHubService` (actor) makes three sequential GitHub REST API calls:

| Call | Endpoint | Purpose |
|------|----------|---------|
| 1 | `GET /repos/{owner}/{repo}` | Resolve default branch |
| 2 | `GET /repos/{owner}/{repo}/git/trees/{branch}?recursive=1` | Full recursive file tree |
| 3 | `GET /repos/{owner}/{repo}/git/blobs/{sha}` ×N | Base64 file content for each candidate |

Authentication is optional. Without a token the GitHub API allows 60 requests/hour. With a Personal Access Token the limit rises to 5,000 requests/hour and private repositories become accessible.

---

### Stage 2 — File Filter

`GitHubTreeResponse.swiftFileCandidates()` applies four filters in order:

1. **Extension** — only `.swift` files
2. **Relevance** — exclude paths containing `tests/`, `.build/`, `pods/`, `generated`, or ending in `Package.swift`
3. **Size** — skip files larger than 60 KB (binary assets, auto-generated code)
4. **Cap** — take up to 30 files, sorted smallest-first

After download, `GitHubFile.containsUICode` applies a second pass:

```swift
content.contains("UIViewController")
    || (content.contains("View") && content.contains("body"))
```

Only files passing this check are sent to the AI stage.

---

### Stage 3 — On-Device AI Analysis

`AccessibilityAnalyzer` (actor) creates one `LanguageModelSession` per file using `SystemLanguageModel.default` — the same model that powers Siri and Writing Tools. No data leaves the device.

The session receives:
- **System instructions** — role definition and target audience context
- **User prompt** — file name, up to 10,000 characters of Swift source, and the eight criterion descriptions

The model returns a structured `FileEvaluation` via `session.respond(to:generating: FileEvaluation.self)`:

```swift
@Generable struct FileEvaluation {
    var accessibilityLabels: CriterionFinding
    var dynamicType:         CriterionFinding
    var colorContrast:       CriterionFinding
    var touchTargetSize:     CriterionFinding
    var voiceOverOrder:      CriterionFinding
    var reduceMotion:        CriterionFinding
    var localization:        CriterionFinding
    var colorIndependence:   CriterionFinding
}

@Generable struct CriterionFinding {
    @Guide(.range(0...100)) var score: Int
    var evidence:   String   // most relevant line of code
    var suggestion: String   // one actionable fix
}
```

`@Generable` and `@Guide` constrain the model output to valid structured data — the score is always an integer in 0–100, never free text.

> **Device requirement:** `SystemLanguageModel.default.isAvailable` returns `false` on simulator and on devices without Apple Intelligence. The app surfaces a clear error in this case. Requires iPhone 15 Pro or newer running iOS 26 with Apple Intelligence enabled.

---

### Stage 4 — Report Generation

`EvaluationReport` is pure Swift arithmetic — the model is not involved.

| Computation | Formula |
|-------------|---------|
| **File score** | Average of 8 criterion scores |
| **Criterion average** | Mean across all analyzed files |
| **Global score** | Weighted average using `TargetAudience.criterionWeights` |
| **Priority sort** | `(100 − criterion_avg) × audience_weight` — highest impact first |
| **Top suggestions** | Files with criterion score < 80, sorted ascending, first 3 |

---

## Accessibility Criteria

The model evaluates each file against eight criteria drawn from WCAG 2.1, Apple's Human Interface Guidelines, and iOS Accessibility Programming Guide.

| Criterion | Icon | What is evaluated |
|-----------|------|------------------|
| **Accessibility Labels** | `tag.fill` | `.accessibilityLabel` / `.accessibilityHint` on interactive elements; decorative images hidden from VoiceOver |
| **Dynamic Type** | `textformat.size` | Semantic fonts (`.body`, `.headline`) vs. fixed sizes; frames that would clip scaled text |
| **Color Contrast** | `circle.lefthalf.filled` | Semantic colors vs. hardcoded values that risk failing contrast in dark mode or high-contrast |
| **Touch Target Size** | `hand.point.up.left.fill` | Tappable elements reaching the 44 × 44 pt minimum |
| **VoiceOver Order** | `arrow.up.arrow.down` | Logical reading order; `accessibilityElement(children:)` and sort priority in complex layouts |
| **Reduce Motion** | `wind` | Animations respecting `@Environment(\.accessibilityReduceMotion)`; autoplaying / repeating motion |
| **Localization & RTL** | `globe` | `String(localized:)` / `LocalizedStringKey`; `leading` / `trailing` instead of `left` / `right` |
| **Color Independence** | `paintpalette.fill` | Information conveyed by color having a non-color alternative (icon, text, shape) |

---

## Scoring System

### Score interpretation

| Score | Color | Meaning |
|-------|-------|---------|
| 80 – 100 | Green | Good coverage |
| 50 – 79 | Orange | Partial — improvements recommended |
| 0 – 49 | Red | Critical gaps |

### Global score

The global score is a weighted average that reflects which criteria matter most for the selected audience:

```
globalScore = Σ (criterion_avg × audience_weight) / Σ audience_weight
```

### Priority ranking

Criteria are sorted by potential impact — the ones with the highest gap relative to their audience weight appear first in the report, so the most valuable fixes are always at the top.

---

## Target Audiences

| Audience | Key criteria (weight ≥ 0.8) |
|----------|-----------------------------|
| **Visual Impairment** | Accessibility Labels (1.0) · VoiceOver Order (1.0) · Color Contrast (0.9) · Dynamic Type (0.9) |
| **Motor Impairment** | Touch Target Size (1.0) |
| **Hearing Impairment** | Localization & RTL (0.7) · Color Independence (0.6) · Dynamic Type (0.6) |
| **Neurodivergence** | Reduce Motion (1.0) |
| **Elderly Users** | Dynamic Type (1.0) · Touch Target Size (0.9) · Color Contrast (0.9) |
| **Cognitive Impairment** | Reduce Motion (0.8) · Dynamic Type (0.8) |

---

## Limits & Configuration

All limits are constants in source — change and recompile to adjust.

| Limit | File | Constant | Default | Effect |
|-------|------|----------|---------|--------|
| Max files analyzed | `GitHubTreeResponse.swift:28` | `maxFiles` | **30** | Stops after the 30 smallest Swift files |
| Max file size fetched | `GitHubTreeResponse.swift:28` | `maxFileSize` | **60,000 bytes** | Skips larger files entirely |
| Max content sent to model | `AccessibilityAnalyzer.swift:37` | `maxContentLength` | **10,000 chars** | Truncates file before model sees it |
| GitHub rate limit (no token) | GitHub API | — | **60 req/hr** | Each file costs 1 request; 30-file repo = 32 requests |
| GitHub rate limit (with PAT) | GitHub API | — | **5,000 req/hr** | Entered in-app; stored in Keychain |

---

## Getting Started

### Prerequisites

- **Mac** with Xcode 26 or later
- **XcodeGen** (installed automatically by `scripts/mac-setup.sh`)
- iPhone 15 Pro or later with iOS 26 for full AI analysis (simulator works for GitHub fetch only)

### Simulator

```bash
# 1. Clone
git clone https://github.com/herrdelta83/SalvaSystemsApp.git
cd SalvaSystemsApp

# 2. Install XcodeGen and generate the Xcode project
bash scripts/mac-setup.sh

# 3. Open Xcode
cd frontend/SalvaSystems
open AccessFlow.xcodeproj
```

In Xcode:
1. Select an **iPhone 16 Pro** simulator (iOS 26)
2. Press **⌘R**

> The GitHub fetch and file filter stages run in full. The AI analysis stage will return an error on simulator because Apple Intelligence is not available there.

### Physical iPhone

**1. Connect your iPhone via USB** and tap Trust on the device prompt.

**2. Sign the app**

- Click **AccessFlow** at the top of the Xcode project navigator
- Open the **Signing & Capabilities** tab
- Check **Automatically manage signing**
- Select your Apple ID under **Team** (add one via Xcode → Settings → Accounts if needed — a free account is sufficient for on-device testing)

**3. Select your iPhone** in the Xcode device picker, then press **⌘R**.

**4. Trust the developer certificate on iPhone**

If a "Developer not trusted" alert appears on the device:

```
Settings → General → VPN & Device Management → [your Apple ID] → Trust
```

Press **⌘R** again in Xcode.

**5. Enable Apple Intelligence**

For the AI analysis stage to run, Apple Intelligence must be active on the device:

```
Settings → Apple Intelligence & Siri → Apple Intelligence → On
```

Allow a few minutes on first launch for the model to download.

> **Note:** Apps signed with a free developer account expire after 7 days. Re-running ⌘R in Xcode renews the certificate.

---

## Contributing

### Branch naming

```
Sprint#-ShortDescription
```

Examples: `Sprint1-RepoInputFlow`, `Sprint2-ReportExport`

### Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(scope): short description
```

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance, dependency updates |
| `refactor` | Internal improvement — no behavior change |

Examples:

```
feat(analyzer): add parallel file analysis with TaskGroup
fix(github): handle truncated tree response for large repos
docs(readme): add scoring system section
```
