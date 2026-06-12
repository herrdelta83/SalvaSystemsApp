import Foundation

struct GitHubFile: Identifiable, Hashable, Sendable {
    let path: String
    let sha: String
    let content: String

    var id: String { sha }

    var fileName: String {
        path.split(separator: "/").last.map(String.init) ?? path
    }

    var containsUICode: Bool {
        content.contains("UIViewController")
            || (content.contains("View") && content.contains("body"))
    }
}

// MARK: - Blob response

struct GitHubBlobResponse: Codable, Sendable {
    let sha: String
    let size: Int
    let content: String
    let encoding: String

    enum DecodingFailure: Error, LocalizedError {
        case unsupportedEncoding(String)
        case notValidBase64
        case binaryContent

        var errorDescription: String? {
            switch self {
            case .unsupportedEncoding(let e): "GitHub returned unexpected encoding: \(e)"
            case .notValidBase64:             "File content is not valid base64"
            case .binaryContent:              "File appears to be binary and cannot be analyzed"
            }
        }
    }

    func decodedText() throws -> String {
        guard encoding == "base64" else {
            throw DecodingFailure.unsupportedEncoding(encoding)
        }
        let cleaned = content.replacingOccurrences(of: "\n", with: "")
        guard let data = Data(base64Encoded: cleaned) else {
            throw DecodingFailure.notValidBase64
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw DecodingFailure.binaryContent
        }
        return text
    }
}
