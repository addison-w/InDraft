import Foundation

// MARK: - Request/Response Models

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]

    struct ChatMessage: Codable {
        let role: String
        let content: String
    }
}

struct ChatCompletionResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message

        struct Message: Codable {
            let content: String
        }
    }
}

struct APIErrorResponse: Codable {
    let error: APIError?

    struct APIError: Codable {
        let message: String?
        let type: String?
        let code: String?
    }
}

// MARK: - Result & Error Types

enum ConnectionTestResult: Equatable {
    case success(model: String, latencyMs: Int)
    case failure(message: String)
}

enum ProviderError: Error, Equatable, LocalizedError {
    case authFailed
    case unreachable(url: String)
    case modelNotFound(model: String)
    case timeout
    case unexpectedFormat
    case networkError(underlying: String)

    var errorDescription: String? {
        switch self {
        case .authFailed:
            return "Authentication failed — check your API key"
        case .unreachable(let url):
            return "Could not reach \(url) — check the URL"
        case .modelNotFound(let model):
            return "Model not found: \(model)"
        case .timeout:
            return "Request timed out after 10 seconds"
        case .unexpectedFormat:
            return "Unexpected response format"
        case .networkError(let underlying):
            return "Network error: \(underlying)"
        }
    }
}

// MARK: - Protocol

protocol ProviderServiceProtocol {
    func transform(text: String, prompt: String, baseURL: String, apiKey: String, model: String, timeout: TimeInterval) async throws -> String
    func testConnection(baseURL: String, apiKey: String, model: String, timeout: TimeInterval) async -> ConnectionTestResult
}

// MARK: - Live Implementation

final class LiveProviderService: ProviderServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func transform(text: String, prompt: String, baseURL: String, apiKey: String, model: String, timeout: TimeInterval = 60) async throws -> String {
        let request = try buildRequest(baseURL: baseURL, apiKey: apiKey, model: model, systemPrompt: prompt, userContent: text, timeout: timeout)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .timedOut {
            throw ProviderError.timeout
        } catch let error as URLError where error.code == .cannotConnectToHost
            || error.code == .cannotFindHost
            || error.code == .notConnectedToInternet
            || error.code == .networkConnectionLost {
            throw ProviderError.unreachable(url: baseURL)
        } catch {
            throw ProviderError.networkError(underlying: error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProviderError.unexpectedFormat
        }

        switch httpResponse.statusCode {
        case 200:
            return try parseResponse(data)
        case 401:
            throw ProviderError.authFailed
        case 404:
            throw ProviderError.modelNotFound(model: model)
        default:
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
               let message = apiError.error?.message {
                throw ProviderError.networkError(underlying: message)
            }
            throw ProviderError.unexpectedFormat
        }
    }

    func testConnection(baseURL: String, apiKey: String, model: String, timeout: TimeInterval = 60) async -> ConnectionTestResult {
        let start = CFAbsoluteTimeGetCurrent()
        do {
            let _ = try await transform(text: "Reply with OK", prompt: "Reply with OK", baseURL: baseURL, apiKey: apiKey, model: model, timeout: timeout)
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            let latencyMs = Int(elapsed * 1000)
            return .success(model: model, latencyMs: latencyMs)
        } catch let error as ProviderError {
            return .failure(message: error.errorDescription ?? "Unknown error")
        } catch {
            return .failure(message: error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    private static let baseSystemPrompt = """
        STRICT OUTPUT RULES (always enforced, overrides all other instructions):
        1. Output ONLY the transformed text. Nothing else.
        2. Strip all ** markers from output.
        3. Replace all — (em dash) with - (hyphen).
        4. Add no formatting beyond what the input contained.
        5. Preserve all emojis from the original input as-is.
        """

    private func buildRequest(baseURL: String, apiKey: String, model: String, systemPrompt: String, userContent: String, timeout: TimeInterval = 60) throws -> URLRequest {
        let urlString = baseURL.hasSuffix("/")
            ? "\(baseURL)chat/completions"
            : "\(baseURL)/chat/completions"

        guard let url = URL(string: urlString) else {
            throw ProviderError.unreachable(url: baseURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout

        let fullSystemPrompt = Self.baseSystemPrompt + "\n\n" + systemPrompt

        let body = ChatCompletionRequest(
            model: model,
            messages: [
                .init(role: "system", content: fullSystemPrompt),
                .init(role: "user", content: userContent)
            ]
        )
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func parseResponse(_ data: Data) throws -> String {
        let decoded: ChatCompletionResponse
        do {
            decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        } catch {
            throw ProviderError.unexpectedFormat
        }

        guard let content = decoded.choices.first?.message.content else {
            throw ProviderError.unexpectedFormat
        }
        return content
    }
}

// MARK: - Mock Implementation

final class MockProviderService: ProviderServiceProtocol {
    var transformResult: Result<String, Error> = .success("Mock response")
    var connectionTestResult: ConnectionTestResult = .success(model: "mock-model", latencyMs: 42)
    var transformCallCount = 0
    var testConnectionCallCount = 0
    var lastTransformText: String?
    var lastTransformPrompt: String?

    func transform(text: String, prompt: String, baseURL: String, apiKey: String, model: String, timeout: TimeInterval = 60) async throws -> String {
        transformCallCount += 1
        lastTransformText = text
        lastTransformPrompt = prompt
        return try transformResult.get()
    }

    func testConnection(baseURL: String, apiKey: String, model: String, timeout: TimeInterval = 60) async -> ConnectionTestResult {
        testConnectionCallCount += 1
        return connectionTestResult
    }
}
