import Foundation
import OSLog
import Testing
@testable import TestingSupport

/// The test suite verifying 9 cases for Data Flow & Value Passthrough.
///   There are 7 positives, 1 negatives, and 1 edge/uncategorized cases.
///
/// (+) Values pass to downstream steps using explicit return
/// (+) Values pass to downstream steps using prefix >>> operator
/// (+) Downstream steps only receive values explicitly re-passed with >>>
/// (+) Values of various string payloads pass through unmodified
/// (+) Accumulated values flatten correctly across steps
/// (+) Values pass directly into pipeline without closure using direct-value given
/// (+) Values pass with explicit type anchor on given block
/// (-) Values with mismatched or thrown states do not reach downstream assertions
/// (?) Unmarked expressions execute as side effects and are excluded from result
@Suite("Data Flow & Value Passthrough", .tags(.dataFlow))
struct DataFlowTests {

    @Test("Values pass to downstream steps using explicit return")
    func valuesPassViaReturnKeyword() {
        given("a greeting message") {
            let greeting = "hello world"
            return greeting
        }
        .then("the greeting is received by the downstream step") { (greeting: String) in
            #expect(greeting == "hello world")
        }
    }

    @Test("Values pass to downstream steps using prefix >>> operator")
    func valuesPassViaPassthroughOperator() {
        given("a greeting message marked with >>>") {
            let greeting = "hello world"
            >>>greeting
        }
        .then("the marked greeting is received by the downstream step") { (greeting: String) in
            #expect(greeting == "hello world")
        }
    }

    @Test("Unmarked expressions execute as side effects and are excluded from result")
    func unmarkedExpressionsAreExcluded() {
        given("mixed marked and unmarked values") {
            >>>1
            Logger.testing.info("side effect two")
            >>>[3]
            let four: Double = 4.0
            >>>four
            print("unmarked side effect")
            >>>(7, 8)
        }
        .then("only values marked with >>> are accumulated in tuple") {
            (one: Int, threeArray: [Int], fourDouble: Double, tuplePair: (Int, Int)) in
            #expect(one == 1)
            #expect(threeArray == [3])
            #expect(fourDouble == 4.0)
            #expect(tuplePair.0 == 7)
            #expect(tuplePair.1 == 8)
        }
    }

    @Test("Downstream steps only receive values explicitly re-passed with >>>")
    func downstreamStepsOnlyReceiveRePassedValues() {
        given("multiple values declared initially") {
            >>>"hello"
            "discarded text"
            >>>" "
            "another discarded text"
            >>>"world"
        }
        .after("intercepting values and only re-passing selected elements") {
            (hello: String, space: String, world: String) in
            >>>hello
            >>>world
        }
        .then("downstream step only receives the re-passed elements") { (hello: String, world: String) in
            #expect(hello == "hello")
            #expect(world == "world")
        }
    }

    @Test(
        "Values of various string payloads pass through unmodified",
        arguments: [
            "plain text",
            "special-characters-!@#$%^&*()",
            "multiline\npayload\ncontent",
            "",
        ]
    )
    func parameterizedStringPassthrough(payload: String) {
        given("a parameterized string payload") {
            >>>payload
        }
        .then("the downstream step receives the exact payload") { (received: String) in
            #expect(received == payload)
        }
    }

    @Test(
        "Accumulated values flatten correctly across steps",
        arguments: [
            (1, 10, 11),
            (5, 20, 25),
            (100, -50, 50),
        ]
    )
    func parameterizedTupleAccumulation(a: Int, b: Int, expectedSum: Int) {
        given("two integers marked for accumulation") {
            >>>a
            >>>b
        }
        .when("calculating their sum") { (first: Int, second: Int) in
            >>>(first + second)
        }
        .then("the calculated sum matches the expected total") { (sum: Int) in
            #expect(sum == expectedSum)
        }
    }

    @Test("Values pass directly into pipeline without closure using direct-value given")
    func directValueGivenPassesToDownstream() {
        given("a banana payload", "Banana")
        .when("measuring string length") { banana in
            >>>(banana.count)
        }
        .then("the count matches expected length") { length in
            #expect(length == 6)
        }

        given("DirectPayload")
        .then("value is forwarded") { payload in
            #expect(payload == "DirectPayload")
        }

        given(value: 999)
        .then("value is forwarded") { (val: Int) in
            #expect(val == 999)
        }

        given("described value", value: "hello")
        .then("value is forwarded") { (val: String) in
            #expect(val == "hello")
        }
    }

    @Test("Values pass with explicit type anchor on given block")
    func explicitTypeAnchorGivenPassesToDownstream() {
        given("a typed banana", of: String.self) {
            >>>"Banana"
        }
        .when("reading character count") { banana in
            >>>(banana.count)
        }
        .then("downstream receives count") { count in
            #expect(count == 6)
        }

        given(of: Int.self) {
            >>>42
        }
        .then("downstream receives integer") { value in
            #expect(value == 42)
        }
    }

    @Test("Values with mismatched or thrown states do not reach downstream assertions")
    func stepFailurePreventsDownstreamDataFlow() {
        var reached = false

        given("valid input") {
            >>>10
        }
        .when("error occurs") { (_: Int) in
            throw ScenarioError.deserializeFailure
            >>>20
        }
        .then("downstream should not be reached") { (_: Int) in
            reached = true
        }

        #expect(reached == false)
    }
}
