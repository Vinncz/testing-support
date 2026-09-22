import Foundation
import Testing
@testable import TestingSupport

@Suite("Asynchronous Concurrency", .tags(.concurrency))
struct ConcurrencyTests {

    @Test("Asynchronous standard keywords chain and execute in sequence")
    func asyncStandardKeywordsExecuteInSequence() async throws {
        var stepLog: [String] = []

        await given("an asynchronous setup") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("given")
        }
        .and("an asynchronous secondary requirement") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("and")
        }
        .with("an asynchronous configuration parameter") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("with")
        }
        .when("an asynchronous operation triggers") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("when")
        }
        .then("the asynchronous assertion completes") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("then")
        }

        #expect(stepLog == ["given", "and", "with", "when", "then"])
    }

    @Test("Asynchronous steps confirm each closure executes exactly once")
    func asyncStepsExecutionConfirmation() async throws {
        await confirmation(expectedCount: 4) { confirm in
            _ = await given("initial step") {
                try? await Task.sleep(nanoseconds: 1_000)
                confirm()
                >>>1
            }
            .and("additive step") { (value: Int) in
                confirm()
                >>>(value + 1)
            }
            .when("action step") { (value: Int) in
                confirm()
                >>>(value * 2)
            }
            .then("assertion step") { (value: Int) in
                confirm()
                #expect(value == 4)
            }
        }
    }

    @Test("Async data flows across multiple async steps using >>>")
    func asyncDataFlowWithPassthrough() async throws {
        await given("an initial user ID fetched asynchronously") {
            try? await Task.sleep(nanoseconds: 1_000)
            let userID = 42
            >>>userID
        }
        .with("a companion profile name") { (userID: Int) in
            try? await Task.sleep(nanoseconds: 1_000)
            let name = "Blob"
            >>>userID
            >>>name
        }
        .when("formatting a summary string") { (userID: Int, name: String) in
            try? await Task.sleep(nanoseconds: 1_000)
            >>>"User #\(userID): \(name)"
        }
        .then("the formatted string matches expectation") { (summary: String) in
            #expect(summary == "User #42: Blob")
        }
    }

    @Test(
        "Async steps process parameterized concurrent inputs correctly",
        arguments: [
            ("api/v1/auth", 200),
            ("api/v1/profile", 200),
            ("api/v1/checkout", 201),
        ]
    )
    func asyncParameterizedRequests(endpoint: String, expectedCode: Int) async throws {
        await given("a simulated endpoint URL") {
            try? await Task.sleep(nanoseconds: 1_000)
            >>>endpoint
        }
        .when("requesting the resource asynchronously") { (path: String) in
            try? await Task.sleep(nanoseconds: 1_000)
            let statusCode = (path == "api/v1/checkout") ? 201 : 200
            >>>statusCode
        }
        .then("the returned status matches the expected code") { (code: Int) in
            #expect(code == expectedCode)
        }
    }

    @Test(
        "Async errors short-circuit downstream async steps",
        arguments: [
            ScenarioError.networkForbidden,
            ScenarioError.networkUnauthenticated,
        ]
    )
    func asyncErrorShortCircuitsDownstream(expectedError: ScenarioError) async {
        var downstreamRan = false
        var finallyRan = false

        do {
            try await given("an async scenario") {
                try await Task.sleep(nanoseconds: 1_000)
                >>>"start"
            }
            .when("an asynchronous error is thrown") { (_: String) async throws -> String in
                try await Task.sleep(nanoseconds: 1_000)
                throw expectedError
                return "fallback"
            }
            .then("downstream async step must be skipped") { (_: String) in
                downstreamRan = true
            }
            .finally("teardown completes unconditionally") {
                finallyRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected error received: \(error)")
        }

        #expect(downstreamRan == false)
        #expect(finallyRan == true)
    }
}
