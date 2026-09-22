import Foundation
import Testing
@testable import TestingSupport

@Suite("Extended Syntactic Sugar", .tags(.extendedSyntax))
struct ExtendedSyntaxTests {

    @Test("Non-standard keywords 'after' and 'should' execute in expected sequence")
    func extendedKeywordsBehaveConsistently() async throws {
        try await given("a mock network request") {
            try await >>>performNetworkRequest()
        }
        .after("the response is received and decoded") { requestResult in
            try >>>simulateDecode(requestResult)
        }
        .should("the payload is recognized and valid") { response in
            guard response != "jumbled mess" else { throw FakeError.deserializeFailure }
            return response
        }
        .then("handle decoded response") { response in
            #expect(response == "valid-response")
        }
        .finally("clean up temporary resources") {}

        func simulateDecode(_: Any) throws -> String { "valid-response" }
        func performNetworkRequest() async throws -> Result<String, FakeError> { .success("payload-data") }
    }

    @Test("Conditional assertion 'should' validates invariants and throws on invalid state")
    func shouldStepValidatesInvariants() async throws {
        var downstreamExecuted = false

        do {
            try given("a payload with invalid state") {
                >>>"corrupted-data"
            }
            .should("be valid data") { (payload: String) throws -> String in
                guard payload == "valid-data" else {
                    throw FakeError.deserializeFailure
                }
                return payload
            }
            .then("downstream step should not execute") { (_: String) in
                downstreamExecuted = true
            }
            .finally("cleanup") {}
        } catch {
            #expect(error as? FakeError == .deserializeFailure)
        }

        #expect(downstreamExecuted == false)
    }
}
