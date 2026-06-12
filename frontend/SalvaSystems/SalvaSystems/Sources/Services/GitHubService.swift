import Foundation

actor GitHubService {
    private let base = "https://api.github.com"
    private let urlSession: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.urlSession = URLSession(configuration: config)
    }

    // MARK: - Public

    func fetchCandidates(owner: String, repo: String, token: String?) async throws -> [GitHubTreeResponse.Entry] {
        let branch = try await defaultBranch(owner: owner, repo: repo, token: token)
        let url = URL(string: "\(base)/repos/\(owner)/\(repo)/git/trees/\(branch)?recursive=1")!
        let tree: GitHubTreeResponse = try await get(url: url, token: token)
        return tree.swiftFileCandidates()
    }

    func fetchFile(
        owner: String, repo: String,
        entry: GitHubTreeResponse.Entry,
        token: String?
    ) async throws -> GitHubFile {
        let url = URL(string: "\(base)/repos/\(owner)/\(repo)/git/blobs/\(entry.sha)")!
        let blob: GitHubBlobResponse = try await get(url: url, token: token)
        let content = try blob.decodedText()
        return GitHubFile(path: entry.path, sha: entry.sha, content: content)
    }

    // MARK: - Private

    private func defaultBranch(owner: String, repo: String, token: String?) async throws -> String {
        struct RepoInfo: Codable { let default_branch: String }
        let url = URL(string: "\(base)/repos/\(owner)/\(repo)")!
        let info: RepoInfo = try await get(url: url, token: token)
        return info.default_branch
    }

    private func get<T: Decodable>(url: URL, token: String?) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        let (data, response) = try await urlSession.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw GitHubError(statusCode: http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Error

struct GitHubError: LocalizedError {
    let statusCode: Int

    var errorDescription: String? {
        switch statusCode {
        case 401: "Invalid GitHub token."
        case 403: "Rate limit exceeded. Add a GitHub token for 5,000 req/hr."
        case 404: "Repository not found. Check the URL and make sure it is public."
        default:  "GitHub API error: HTTP \(statusCode)"
        }
    }
}
