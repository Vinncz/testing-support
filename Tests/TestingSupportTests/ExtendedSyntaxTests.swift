import Foundation
import Testing
@testable import TestingSupport

/// The test suite verifying 6 cases for Extended Syntactic Sugar.
///   There are 3 positives, 2 negatives, and 1 edge/uncategorized cases.
///
/// (+) Synchronous 'after' and 'should' execute in expected sequence
/// (+) Asynchronous 'after' and 'should' execute in expected sequence
/// (+) Overloads without descriptions function identically to described variants
/// (-) Synchronous 'should' step validates invariants and throws on invalid state
/// (-) Asynchronous 'should' step validates invariants and throws on invalid state
/// (?) Pipeline carries forward an error through subsequent extended keywords without executing them
@Suite("Extended Syntactic Sugar", .tags(.extendedSyntax))
struct ExtendedSyntaxTests {

    @Test("Synchronous 'after' and 'should' execute in expected sequence")
    func syncExtendedKeywordsBehaveConsistently() throws {
        var sequence: [String] = []

        try given("sync setup") {
            sequence.append("given")
            >>>"raw-data"
        }
        .when("transforming") { (data: String) in
            sequence.append("when")
            >>>data.uppercased()
        }
        .after("the response is received") { (data: String) in
            sequence.append("after")
            >>>data
        }
        .should("the payload is recognized and valid") { (data: String) throws -> String in
            sequence.append("should")
            guard data == "RAW-DATA" else { throw FakeError.deserializeFailure }
            return data
        }
        .then("handle decoded response") { (data: String) in
            sequence.append("then")
            #expect(data == "RAW-DATA")
        }
        .finally("clean up") {}

        #expect(sequence == ["given", "when", "after", "should", "then"])
    }

    @Test("Asynchronous 'after' and 'should' execute in expected sequence")
    func asyncExtendedKeywordsBehaveConsistently() async throws {
        var sequence: [String] = []

        try await given("a mock network request") {
            await Task.yield()
            sequence.append("given")
            >>>"payload-data"
        }
        .when("action occurs") { (payload: String) in
            await Task.yield()
            sequence.append("when")
            >>>payload
        }
        .after("the response is received and decoded") { (payload: String) in
            await Task.yield()
            sequence.append("after")
            >>>"valid-response"
        }
        .should("the payload is recognized and valid") { (response: String) in
            await Task.yield()
            sequence.append("should")
            guard response != "jumbled mess" else { throw FakeError.deserializeFailure }
            return response
        }
        .then("handle decoded response") { (response: String) in
            sequence.append("then")
            #expect(response == "valid-response")
        }
        .finally("clean up temporary resources") {}

        #expect(sequence == ["given", "when", "after", "should", "then"])
    }

    @Test("Overloads without descriptions function identically to described variants")
    func extendedKeywordsWithoutDescriptions() async throws {
        
        // Sync variants with explicit type anchor and no description
        let syncResult = try given(of: String.self) {
            >>>"sync-sugar"
        }
        .after(of: String.self) { val in
            >>>val
        }
        .should(of: String.self) { val in
            >>>val
        }
        .finally { () }

        #expect(syncResult == "sync-sugar")

        // Async variants with explicit type anchor and no description
        let asyncResult = try await given(of: String.self) {
            await Task.yield()
            >>>"async-sugar"
        }
        .after(of: String.self) { val in
            await Task.yield()
            >>>val
        }
        .should(of: String.self) { val in
            await Task.yield()
            >>>val
        }
        .finally {
            await Task.yield()
        }

        #expect(asyncResult == "async-sugar")
    }

    @Test("Synchronous 'should' step validates invariants and throws on invalid state")
    func syncShouldStepValidatesInvariants() {
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

    @Test("Asynchronous 'should' step validates invariants and throws on invalid state")
    func asyncShouldStepValidatesInvariants() async {
        var downstreamExecuted = false

        do {
            try await given("an async payload with invalid state") {
                await Task.yield()
                >>>"corrupted-async-data"
            }
            .should("be valid async data") { (payload: String) async throws -> String in
                await Task.yield()
                guard payload == "valid-async-data" else {
                    throw FakeError.deserializeFailure
                }
                return payload
            }
            .then("downstream step should not execute") { (_: String) in
                downstreamExecuted = true
            }
            .finally("cleanup") {
                await Task.yield()
            }
        } catch {
            #expect(error as? FakeError == .deserializeFailure)
        }

        #expect(downstreamExecuted == false)
    }

    @Test("Pipeline carries forward an error through subsequent extended keywords without executing them")
    func errorCarriedThroughExtendedKeywords() async {
        var afterRan = false
        var shouldRan = false

        do {
            try given("initial throwing step") {
                throw FakeError.networkForbidden
                >>>"never"
            }
            .after("should be skipped") { (_: String) in
                afterRan = true
                >>>"skipped"
            }
            .should("should be skipped") { (_: String) in
                shouldRan = true
                return "skipped"
            }
            .finally {}
        } catch {
            #expect(error as? FakeError == .networkForbidden)
        }

        #expect(afterRan == false)
        #expect(shouldRan == false)

        var asyncAfterRan = false
        var asyncShouldRan = false

        do {
            try await given("async throwing step") {
                await Task.yield()
                throw FakeError.networkForbidden
                >>>"never"
            }
            .after("async after skipped") { (_: String) in
                await Task.yield()
                asyncAfterRan = true
                >>>"skipped"
            }
            .should("async should skipped") { (_: String) in
                await Task.yield()
                asyncShouldRan = true
                return "skipped"
            }
            .finally {
                await Task.yield()
            }
        } catch {
            #expect(error as? FakeError == .networkForbidden)
        }

        #expect(asyncAfterRan == false)
        #expect(asyncShouldRan == false)
    }
}
