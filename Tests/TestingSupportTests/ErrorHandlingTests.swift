import Foundation
import Testing
@testable import TestingSupport

@Suite("Error Handling & Pipeline Short-Circuiting", .tags(.errorHandling))
struct ErrorHandlingTests {

    @Test("Finally block executes unconditionally even after an error is thrown")
    func finallyBlockExecutesAfterError() async {
        var finallyExecuted = false

        do {
            try given("making a network call") {
                >>>"payload"
            }
            .after("the response is received") { (_: String) throws -> String in
                throw ScenarioError.deserializeFailure
                return "response"
            }
            .should("contain valid data") { (response: String) in
                #expect(response.isEmpty == false)
            }
            .then("proceed normally") {}
            .finally("perform mandatory cleanup") {
                finallyExecuted = true
            }
        } catch {
            #expect(error as? ScenarioError == .deserializeFailure)
        }

        #expect(finallyExecuted == true)
    }

    @Test(
        "Errors thrown in intermediate steps short-circuit all subsequent steps",
        arguments: [
            ScenarioError.networkTimeout,
            ScenarioError.deserializeFailure,
            ScenarioError.diskFull,
        ]
    )
    func errorShortCircuitsDownstreamSteps(expectedError: ScenarioError) async {
        var downstreamStepRan = false
        var cleanupRan = false

        do {
            try given("an initial successful setup") {
                >>>100
            }
            .when("a failure occurs") { (_: Int) throws -> Int in
                throw expectedError
                return 0
            }
            .then("this downstream step must be skipped") { (_: Int) in
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

    @Test("Finally block returns the final pipeline value when all steps succeed")
    func finallyReturnsFinalValueOnSuccess() throws {
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
}
