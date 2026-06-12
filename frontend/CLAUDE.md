# Frontend Guidelines

## Communication Protocol (Caveman Mode)
Respond terse like smart caveman. All technical substance stay. Only fluff die.
* Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging.
* Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
* Pattern: [thing] [action] [reason]. [next step].
* Boundaries: Code blocks, commit messages, and security warnings must be written in normal English.

## SwiftUI & Platform Skills
* Apply community-maintained best practices for SwiftUI design principles and view refactoring.
* Leverage modern Swift Concurrency and SwiftData optimally.
* Design all UI components specifically for iPad touch targets and horizontal screen real estate.
* Prioritize robust offline-first data capture capabilities for rural environments.

## General Project Structure
* `Sources/App/`: App entry point and Root View.
* `Sources/Features/`: Feature-based folders with `Models/`, `Views/`, `ViewModels/` inside each.
* `Sources/Shared/`: Reusable UI components and SwiftUI modifiers.
* `Sources/Utils/`: Extensions and helpers.

---

## AccessFlow — Frontend Structure Rules

Architecture: MVVM per feature. No exceptions.

### File placement — mandatory on every frontend change

| What you're adding | Where it goes |
|---|---|
| New screen or feature-specific component | `AccessFlow/Sources/Features/<Feature>/Views/` |
| Feature-specific data model | `AccessFlow/Sources/Features/<Feature>/Models/` |
| State / presentation logic for a feature | `AccessFlow/Sources/Features/<Feature>/ViewModels/` |
| Reusable visual component (cross-feature) | `AccessFlow/Sources/Shared/Components/` |
| Design tokens (colors, typography, spacing) | `AccessFlow/Sources/Shared/DesignSystem/` |
| Accessibility modifier / extension | `AccessFlow/Sources/Shared/Accessibility/` |
| Swift/Foundation/SwiftUI type extension | `AccessFlow/Sources/Shared/Extensions/` |
| Global constant | `AccessFlow/Sources/Utils/Constants/` |
| Pure utility function / helper | `AccessFlow/Sources/Utils/Helpers/` |
| Input validator | `AccessFlow/Sources/Utils/Validators/` |
| JSON fixture / test screenshot | `AccessFlow/Sources/Resources/Fixtures/` |
| CoreML model file | `AccessFlow/Sources/Resources/MLModels/` |

**Engine logic (Core) and documentation (Docs) live in `backend/` — never in frontend.**

### Layer invariants

- `Views/` contains only SwiftUI layout and presentation. No business logic.
- `ViewModels/` may reference `backend/Core/` but must NOT import `SwiftUI` or `UIKit`.
- Shared models go in `backend/Core/Models/`; feature-local models go in `Features/<X>/Models/`.
- Empty directories keep a `.gitkeep` until they contain real Swift code.

### Features in AccessFlow

| Feature | Responsibility |
|---|---|
| Home | Explanation screens, entry points for audit / import / sample |
| GuidedAudit | Step-by-step manual audit: task, profile, issue, blocking check, analysis |
| AuditImport | `.accessflow.json` import, validation, preloaded samples |
| Dashboard | Release recommendation, severity distribution, blocking issues, affected profiles |
| Regression | v1 vs v2 diff: new / fixed / worsened issues |
| IssueDetail | Per-issue detail: failure, broken task, affected profiles, severity, impact |
| Recommendations | SwiftUI fix recommendations, code snippets, curated fix library |
| Reports | Actionable report, future export, release decision |

### Xcode integration note

`AccessFlow/Sources/` is a physical folder on disk. After syncing from git on Mac, drag `Sources/` into the Xcode project navigator (Add Files to Project > Create groups) so it becomes an Xcode group. Do not re-add `AccessFlowApp.swift` — the entry point already exists at the Xcode project root.
