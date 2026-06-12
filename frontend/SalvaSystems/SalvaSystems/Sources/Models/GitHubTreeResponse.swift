import Foundation

struct GitHubTreeResponse: Codable, Sendable {
    let sha: String
    let tree: [Entry]
    let truncated: Bool

    struct Entry: Codable, Hashable, Sendable {
        let path: String
        let type: String
        let sha: String
        let size: Int?

        var isSwiftFile: Bool {
            type == "blob" && path.hasSuffix(".swift")
        }

        var isLikelyIrrelevant: Bool {
            let lowered = path.lowercased()
            return lowered.contains("tests/")
                || lowered.contains(".build/")
                || lowered.contains("pods/")
                || lowered.contains("generated")
                || lowered.hasSuffix("package.swift")
        }
    }

    func swiftFileCandidates(maxFileSize: Int = 60_000, maxFiles: Int = 30) -> [Entry] {
        tree
            .filter { $0.isSwiftFile && !$0.isLikelyIrrelevant }
            .filter { ($0.size ?? 0) <= maxFileSize }
            .sorted { ($0.size ?? 0) < ($1.size ?? 0) }
            .prefix(maxFiles)
            .map { $0 }
    }
}
