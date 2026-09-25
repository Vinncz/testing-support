import Foundation
import Testing
@testable import TestingSupport

/// The test suite verifying 7 cases for Asynchronous Concurrency.
///   There are 4 positives, 2 negatives, and 1 edge/uncategorized cases.
///
/// (+) Asynchronous standard keywords chain and execute in sequence
/// (+) Asynchronous steps confirm each closure executes exactly once
/// (+) Async data flows across multiple async steps using >>>
/// (+) Asynchronous direct value and pre-existing value initialization overloads
/// (-) Asynchronous step failure short-circuits downstream async steps
/// (-) Asynchronous step throws error propagating to caller
/// (?) Asynchronous steps process parameterized concurrent inputs correctly
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
        .but("an asynchronous exclusion applies") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("but")
        }
        .then("the asynchronous assertion completes") {
            try? await Task.sleep(nanoseconds: 1_000)
            stepLog.append("then")
        }

        #expect(stepLog == ["given", "and", "with", "when", "but", "then"])
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

    @Test("Asynchronous direct value and pre-existing value initialization overloads")
    func asyncDirectValueInitialization() async {
        await given("an explicit async value with description", value: "AsyncValue")
        .then("receives the initial value") { (val: String) in
            #expect(val == "AsyncValue")
        }

        await given(value: 42)
        .then("receives the initial integer without description") { (val: Int) in
            #expect(val == 42)
        }

        await given("a pre-existing async value with description", [1, 2, 3])
        .then("receives the pre-existing array") { (list: [Int]) in
            #expect(list == [1, 2, 3])
        }

        await given(99.9)
        .then("receives the pre-existing double without description") { (num: Double) in
            #expect(num == 99.9)
        }

        // Test undescribed variants with type anchors and closures
        await given(of: String.self) {
            await Task.yield()
            >>>"undescribed-given"
        }
        .with(of: (String, Int).self) { str in
            await Task.yield()
            >>>str
            >>>7
        }
        .when(of: String.self) { str, count in
            await Task.yield()
            >>>"\(str)-\(count)"
        }
        .and(of: String.self) { res in
            await Task.yield()
            >>>res
        }
        .but(of: String.self) { res in
            await Task.yield()
            >>>res
        }
        .then(of: Void.self) { res in
            await Task.yield()
            #expect(res == "undescribed-given-7")
        }
    }

    @Test(
        "Asynchronous step failure short-circuits downstream async steps",
        arguments: [
            ScenarioError.networkForbidden,
            ScenarioError.networkUnauthenticated,
        ]
    )
    func asyncErrorShortCircuitsDownstream(expectedError: ScenarioError) async {
        var downstreamRan = false
        var finallyRan = false

        func simulateAsyncFailure() async throws {
            try await Task.sleep(nanoseconds: 1_000)
            throw expectedError
        }

        do {
            try await given("an async scenario") {
                try await Task.sleep(nanoseconds: 1_000)
                >>>"start"
            }
            .when("an asynchronous error is thrown") { (_: String) in
                try await simulateAsyncFailure()
            }
            .then("downstream async step must be skipped") { () in
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

    @Test("Asynchronous step throws error propagating to caller")
    func asyncStepThrowsPropagates() async {
        var downstreamRan = false

        await given("an async starting step") {
            await Task.yield()
            throw ScenarioError.networkTimeout
            >>>123
        }
        .and("async and step") { (num: Int) in
            await Task.yield()
            downstreamRan = true
            >>>num
        }
        .then("async then step") { (_: Int) in
            await Task.yield()
            downstreamRan = true
        }

        #expect(downstreamRan == false)
    }

    @Test(
        "Asynchronous steps process parameterized concurrent inputs correctly",
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
}
