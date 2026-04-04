import XCTest
@testable import InDraft

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("No request handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Tests

final class ProviderServiceTests: XCTestCase {
    private var session: URLSession!
    private var service: LiveProviderService!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        service = LiveProviderService(session: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        session = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Request Building

    func testBuildsChatCompletionRequestCorrectly() async throws {
        var capturedURL: URL?
        var capturedMethod: String?
        var capturedAuth: String?
        var capturedContentType: String?
        var capturedBody: ChatCompletionRequest?

        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            capturedMethod = request.httpMethod
            capturedAuth = request.value(forHTTPHeaderField: "Authorization")
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            if let bodyStream = request.httpBodyStream {
                bodyStream.open()
                let bufferSize = 4096
                var data = Data()
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { buffer.deallocate() }
                while bodyStream.hasBytesAvailable {
                    let read = bodyStream.read(buffer, maxLength: bufferSize)
                    if read > 0 {
                        data.append(buffer, count: read)
                    }
                }
                bodyStream.close()
                capturedBody = try? JSONDecoder().decode(ChatCompletionRequest.self, from: data)
            } else if let httpBody = request.httpBody {
                capturedBody = try? JSONDecoder().decode(ChatCompletionRequest.self, from: httpBody)
            }
            let json = self.validResponseJSON("Transformed text")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let _ = try await service.transform(
            text: "Hello world",
            prompt: "Fix grammar",
            baseURL: "https://api.example.com/v1",
            apiKey: "sk-test-key",
            model: "gpt-4"
        )

        XCTAssertEqual(capturedURL?.absoluteString, "https://api.example.com/v1/chat/completions")
        XCTAssertEqual(capturedMethod, "POST")
        XCTAssertEqual(capturedAuth, "Bearer sk-test-key")
        XCTAssertEqual(capturedContentType, "application/json")

        let body = try XCTUnwrap(capturedBody)
        XCTAssertEqual(body.model, "gpt-4")
        XCTAssertEqual(body.messages.count, 2)
        XCTAssertEqual(body.messages[0].role, "system")
        XCTAssertTrue(body.messages[0].content.contains("Fix grammar"))
        XCTAssertEqual(body.messages[1].role, "user")
        XCTAssertEqual(body.messages[1].content, "Hello world")
    }

    // MARK: - Response Parsing

    func testParsesValidResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            let json = self.validResponseJSON("The corrected text")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let result = try await service.transform(
            text: "input",
            prompt: "prompt",
            baseURL: "https://api.example.com/v1",
            apiKey: "key",
            model: "gpt-4"
        )

        XCTAssertEqual(result, "The corrected text")
    }

    // MARK: - Error Handling

    func testHandles401AuthError() async {
        MockURLProtocol.requestHandler = { request in
            let json = """
            {"error": {"message": "Invalid API key", "type": "invalid_request_error"}}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        do {
            let _ = try await service.transform(
                text: "input",
                prompt: "prompt",
                baseURL: "https://api.example.com/v1",
                apiKey: "bad-key",
                model: "gpt-4"
            )
            XCTFail("Expected authFailed error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .authFailed)
            XCTAssertEqual(error.errorDescription, "Authentication failed — check your API key")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testHandles404ModelNotFound() async {
        MockURLProtocol.requestHandler = { request in
            let json = """
            {"error": {"message": "Model not found", "type": "invalid_request_error"}}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        do {
            let _ = try await service.transform(
                text: "input",
                prompt: "prompt",
                baseURL: "https://api.example.com/v1",
                apiKey: "key",
                model: "nonexistent-model"
            )
            XCTFail("Expected modelNotFound error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .modelNotFound(model: "nonexistent-model"))
            XCTAssertEqual(error.errorDescription, "Model not found: nonexistent-model")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testHandlesNetworkError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.cannotConnectToHost)
        }

        do {
            let _ = try await service.transform(
                text: "input",
                prompt: "prompt",
                baseURL: "https://unreachable.example.com/v1",
                apiKey: "key",
                model: "gpt-4"
            )
            XCTFail("Expected unreachable error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .unreachable(url: "https://unreachable.example.com/v1"))
            XCTAssert(error.errorDescription!.contains("Could not reach"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testHandlesTimeout() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        do {
            let _ = try await service.transform(
                text: "input",
                prompt: "prompt",
                baseURL: "https://api.example.com/v1",
                apiKey: "key",
                model: "gpt-4"
            )
            XCTFail("Expected timeout error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .timeout)
            XCTAssertEqual(error.errorDescription, "Request timed out after 10 seconds")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testHandlesUnexpectedResponseFormat() async {
        MockURLProtocol.requestHandler = { request in
            let json = """
            {"unexpected": "format"}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        do {
            let _ = try await service.transform(
                text: "input",
                prompt: "prompt",
                baseURL: "https://api.example.com/v1",
                apiKey: "key",
                model: "gpt-4"
            )
            XCTFail("Expected unexpectedFormat error")
        } catch let error as ProviderError {
            XCTAssertEqual(error, .unexpectedFormat)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Connection Test

    func testConnectionTestSuccess() async {
        MockURLProtocol.requestHandler = { request in
            let json = self.validResponseJSON("OK")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let result = await service.testConnection(
            baseURL: "https://api.example.com/v1",
            apiKey: "key",
            model: "gpt-4"
        )

        if case let .success(model, latencyMs) = result {
            XCTAssertEqual(model, "gpt-4")
            XCTAssertGreaterThanOrEqual(latencyMs, 0)
        } else {
            XCTFail("Expected success result, got \(result)")
        }
    }

    func testConnectionTestFailureReturnsMessage() async {
        MockURLProtocol.requestHandler = { request in
            let json = """
            {"error": {"message": "Invalid API key"}}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let result = await service.testConnection(
            baseURL: "https://api.example.com/v1",
            apiKey: "bad-key",
            model: "gpt-4"
        )

        if case let .failure(message) = result {
            XCTAssertEqual(message, "Authentication failed — check your API key")
        } else {
            XCTFail("Expected failure result, got \(result)")
        }
    }

    // MARK: - Mock Service

    func testMockServiceReturnsConfiguredResult() async throws {
        let mock = MockProviderService()
        mock.transformResult = .success("Custom result")

        let result = try await mock.transform(
            text: "input",
            prompt: "prompt",
            baseURL: "https://api.example.com/v1",
            apiKey: "key",
            model: "gpt-4"
        )

        XCTAssertEqual(result, "Custom result")
        XCTAssertEqual(mock.transformCallCount, 1)
        XCTAssertEqual(mock.lastTransformText, "input")
        XCTAssertEqual(mock.lastTransformPrompt, "prompt")
    }

    func testMockServiceReturnsConfiguredConnectionResult() async {
        let mock = MockProviderService()
        mock.connectionTestResult = .failure(message: "Test failure")

        let result = await mock.testConnection(
            baseURL: "https://api.example.com/v1",
            apiKey: "key",
            model: "gpt-4"
        )

        XCTAssertEqual(result, .failure(message: "Test failure"))
        XCTAssertEqual(mock.testConnectionCallCount, 1)
    }

    // MARK: - Helpers

    private func validResponseJSON(_ content: String) -> Data {
        """
        {
            "id": "chatcmpl-test",
            "object": "chat.completion",
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": "\(content)"
                    },
                    "finish_reason": "stop"
                }
            ]
        }
        """.data(using: .utf8)!
    }
}
