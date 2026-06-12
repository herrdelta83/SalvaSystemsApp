import Foundation
import Observation

@Observable
@MainActor
final class EvaluationViewModel {

    // MARK: - Input state
    var repoURL:         String = ""
    var selectedAudience: TargetAudience = .elderly
    var githubToken:     String = ""

    // MARK: - Run state
    enum RunState: Equatable {
        case idle
        case loading(message: String)
        case analyzing(fileName: String, progress: Double)
        case done
        case failed(String)
    }

    var state: RunState = .idle
    var report: EvaluationReport?

    // Used to drive animation key in App
    var screenTag: Int = 0

    var isRunning: Bool {
        switch state {
        case .loading, .analyzing: true
        default: false
        }
    }

    // MARK: - Services
    private let github   = GitHubService()
    private let analyzer = AccessibilityAnalyzer()

    // MARK: - URL parsing

    func parseOwnerRepo() -> (owner: String, repo: String)? {
        var input = repoURL
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "https://github.com/", with: "")
            .replacingOccurrences(of: "http://github.com/", with: "")
            .replacingOccurrences(of: "github.com/", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        // Strip trailing .git
        if input.hasSuffix(".git") { input = String(input.dropLast(4)) }

        let parts = input.split(separator: "/").map(String.init)
        guard parts.count >= 2 else { return nil }
        return (parts[0], parts[1])
    }

    // MARK: - Main evaluation flow

    func startEvaluation() async {
        guard let (owner, repo) = parseOwnerRepo() else {
            state = .failed("Invalid URL. Use: github.com/owner/repo")
            return
        }

        let token: String? = githubToken.isEmpty
            ? KeychainHelper.retrieve()
            : githubToken
        if !githubToken.isEmpty { KeychainHelper.save(token: githubToken) }

        screenTag += 1

        do {
            // 1. Fetch file list
            state = .loading(message: "Fetching \(owner)/\(repo)…")
            let candidates = try await github.fetchCandidates(owner: owner, repo: repo, token: token)

            guard !candidates.isEmpty else {
                state = .failed("No eligible Swift files found.")
                return
            }

            // 2. Download + filter files with UI code
            state = .loading(message: "Downloading \(candidates.count) Swift files…")
            var uiFiles: [GitHubFile] = []
            for entry in candidates {
                guard let file = try? await github.fetchFile(
                    owner: owner, repo: repo, entry: entry, token: token
                ) else { continue }
                if file.containsUICode { uiFiles.append(file) }
            }

            guard !uiFiles.isEmpty else {
                state = .failed("No SwiftUI/UIKit view files found in this repository.")
                return
            }

            // 3. Analyze each file with Foundation Models
            var records: [FileEvaluationRecord] = []
            for (index, file) in uiFiles.enumerated() {
                state = .analyzing(
                    fileName: file.fileName,
                    progress: Double(index) / Double(uiFiles.count)
                )
                let evaluation = try await analyzer.analyze(file: file, audience: selectedAudience)
                records.append(FileEvaluationRecord(path: file.path, evaluation: evaluation))
            }

            // 4. Build report
            report = EvaluationReport(
                repositoryName: "\(owner)/\(repo)",
                audience: selectedAudience,
                records: records
            )
            state = .done
            screenTag += 1

        } catch {
            state = .failed(error.localizedDescription)
            screenTag += 1
        }
    }

    func reset() {
        state = .idle
        report = nil
        repoURL = ""
        githubToken = ""
        screenTag += 1
    }
}
