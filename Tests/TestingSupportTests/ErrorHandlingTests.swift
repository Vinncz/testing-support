import Foundation
import Testing
@testable import TestingSupport

/// The test suite verifying 6 cases for Error Handling & Pipeline Short-Circuiting.
///   There are 2 positives, 3 negatives, and 1 edge/uncategorized cases.
///
/// (+) Synchronous pipeline succeeds and returns the accumulated value from finally
/// (+) Asynchronous pipeline succeeds and returns the accumulated value from async finally
/// (-) Errors thrown in intermediate synchronous steps short-circuit all subsequent steps
/// (-) Errors thrown in intermediate asynchronous steps short-circuit all subsequent steps
/// (-) Errors thrown in initial setup step (given) short-circuit before any steps run
/// (?) Finally block executes unconditionally even after an error is thrown (sync and async)
@Suite("Error Handling & Pipeline Short-Circuiting", .tags(.errorHandling))
struct ErrorHandlingTests {

    @Test("Synchronous pipeline succeeds and returns the accumulated value from finally")
    func synchronousFinallyReturnsFinalValueOnSuccess() throws {
        let finalResult = try given("an initial count") {
            >>>10
        }
        .when("multiplying by two") { (count: Int) in
            >>>(count * 2)
        }
        .then("adding five") { (count: Int) in
            >>>(count + 5)
        }
        .finally("cleanup resources") {}

        #expect(finalResult == 25)
    }

    @Test("Asynchronous pipeline succeeds and returns the accumulated value from async finally")
    func asynchronousFinallyReturnsFinalValueOnSuccess() async throws {
        let finalResult = try await given("an initial async count") {
            await Task.yield()
            >>>10
        }
        .when("doubling asynchronously") { (count: Int) in
            await Task.yield()
            >>>(count * 2)
        }
        .then("incrementing asynchronously") { (count: Int) in
            await Task.yield()
            >>>(count + 5)
        }
        .finally("clean up async resources") {
            await Task.yield()
        }

        #expect(finalResult == 25)
    }

    @Test(
        "Errors thrown in intermediate synchronous steps short-circuit all subsequent steps",
        arguments: [
            ScenarioError.networkTimeout,
            ScenarioError.deserializeFailure,
            ScenarioError.diskFull,
        ]
    )
    func syncErrorShortCircuitsDownstreamSteps(expectedError: ScenarioError) {
        var downstreamStepRan = false
        var cleanupRan = false

        do {
            try given("an initial successful setup") {
                >>>100
            }
            .when("a failure occurs") { (_: Int) in
                throw expectedError
            }
            .then("this downstream step must be skipped") { () in
                downstreamStepRan = true
            }
            .finally("cleanup runs unconditionally") {
                cleanupRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected error received: \(error)")
        }

        #expect(downstreamStepRan == false)
        #expect(cleanupRan == true)
    }

    @Test(
        "Errors thrown in intermediate asynchronous steps short-circuit all subsequent steps",
        arguments: [
            ScenarioError.networkForbidden,
            ScenarioError.networkUnauthenticated,
        ]
    )
    func asyncErrorShortCircuitsDownstreamSteps(expectedError: ScenarioError) async {
        var downstreamRan = false
        var cleanupRan = false

        do {
            try await given("an async scenario") {
                await Task.yield()
                >>>"start"
            }
            .when("an asynchronous error is thrown") { (_: String) in
                await Task.yield()
                throw expectedError
            }
            .then("downstream async step must be skipped") { () in
                downstreamRan = true
            }
            .finally("teardown completes unconditionally") {
                await Task.yield()
                cleanupRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected error received: \(error)")
        }

        #expect(downstreamRan == false)
        #expect(cleanupRan == true)
    }

    @Test("Errors thrown in initial setup step (given) short-circuit before any steps run")
    func initialSetupErrorsPropagateAndShortCircuit() async {
        var syncStepRan = false
        var syncCleanupRan = false

        do {
            try given("a failing synchronous setup") {
                throw ScenarioError.diskFull
                >>>"never-reached"
            }
            .then("downstream step skipped") { (_: String) in
                syncStepRan = true
            }
            .finally("cleanup runs") {
                syncCleanupRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == .diskFull)
        } catch {
            Issue.record("Unexpected error received: \(error)")
        }

        #expect(syncStepRan == false)
        #expect(syncCleanupRan == true)

        var asyncStepRan = false
        var asyncCleanupRan = false

        do {
            try await given("a failing asynchronous setup") {
                await Task.yield()
                throw ScenarioError.networkForbidden
                >>>"never-reached"
            }
            .then("downstream async step skipped") { (_: String) in
                asyncStepRan = true
            }
            .finally("async cleanup runs") {
                await Task.yield()
                asyncCleanupRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == .networkForbidden)
        } catch {
            Issue.record("Unexpected error received: \(error)")
        }

        #expect(asyncStepRan == false)
        #expect(asyncCleanupRan == true)

        // Also test typed given throwing
        do {
            try given("failing typed setup", of: Int.self) {
                throw ScenarioError.deserializeFailure
                >>>42
            }
            .then("should not run") { _ in }
            .finally {
                syncCleanupRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == .deserializeFailure)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        do {
            try await given("failing async typed setup", of: Int.self) {
                await Task.yield()
                throw ScenarioError.networkTimeout
                >>>42
            }
            .then("should not run") { _ in }
            .finally {
                await Task.yield()
                asyncCleanupRan = true
            }
        } catch let error as ScenarioError {
            #expect(error == .networkTimeout)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Finally block executes unconditionally even after an error is thrown (sync and async)")
    func finallyBlockExecutesAfterError() async {
        var syncFinallyExecuted = false

        do {
            try given("making a synchronous call") {
                >>>"payload"
            }
            .after("the response is received") { (_: String) in
                throw ScenarioError.deserializeFailure
            }
            .should("contain valid data") { () in }
            .then("proceed normally") {}
            .finally("perform mandatory cleanup") {
                syncFinallyExecuted = true
            }
        } catch {
            #expect(error as? ScenarioError == .deserializeFailure)
        }

        #expect(syncFinallyExecuted == true)

        var asyncFinallyExecuted = false

        do {
            try await given("making an asynchronous call") {
                await Task.yield()
                >>>"async-payload"
            }
            .after("async response received") { (_: String) in
                await Task.yield()
                throw ScenarioError.networkTimeout
            }
            .should("be valid") { () in }
            .then("not reached") {}
            .finally("perform mandatory async cleanup") {
                await Task.yield()
                asyncFinallyExecuted = true
            }
        } catch {
            #expect(error as? ScenarioError == .networkTimeout)
        }

        #expect(asyncFinallyExecuted == true)
    }
}
