import Foundation
import Testing
@testable import TestingSupport

/// The test suite verifying 7 cases for Standard Gherkin Keywords.
///   There are 5 positives, 1 negatives, and 1 edge/uncategorized cases.
///
/// (+) Standard Gherkin keyword chain (given -> when -> then) executes in sequential order
/// (+) Additive and contrasting keywords (but, and) execute in sequence
/// (+) Multiple action and verification steps execute in sequence
/// (+) Auxiliary configuration step 'with' supplies parallel context
/// (+) Step methods without descriptions execute in identical sequence
/// (-) Step failure bypasses downstream steps in standard chain
/// (?) Chaining empty or repeated steps retains pipeline validity
@Suite("Standard Gherkin Keywords", .tags(.standardKeywords))
struct StandardKeywordTests {

    @Test("Standard Gherkin keyword chain (given -> when -> then) executes in sequential order")
    func standardKeywordChainExecutesInSequence() {
        var executionTrail: [String] = []

        given("heavy rain befalls Greater Jakarta") {
            executionTrail.append("given")
        }
        .when("it does not stop within two hours") {
            executionTrail.append("when")
        }
        .then("the office is expected to be empty") {
            executionTrail.append("then")
        }

        #expect(executionTrail == ["given", "when", "then"])
    }

    @Test("Additive and contrasting keywords (but, and) execute in sequence")
    func additiveAndContrastingKeywordsExecuteInSequence() {
        var executionTrail: [String] = []

        given("a difficult math problem") {
            executionTrail.append("given")
        }
        .but("the mind is distracted") {
            executionTrail.append("but")
        }
        .when("asked to answer the question") {
            executionTrail.append("when")
        }
        .then("an incorrect answer is submitted") {
            executionTrail.append("then")
        }
        .and("the student is ridiculed") {
            executionTrail.append("and")
        }

        #expect(executionTrail == ["given", "but", "when", "then", "and"])
    }

    @Test("Multiple action and verification steps execute in sequence")
    func multipleActionStepsExecuteInSequence() {
        var stepsTaken: [String] = []

        given("queuing at a food court counter") {
            stepsTaken.append("queue")
        }
        .when("ordering a curry meal") {
            stepsTaken.append("order")
        }
        .then("prepare phone to pay with digital code") {
            stepsTaken.append("prepare-digital-payment")
        }
        .but("internet connectivity is down") {
            stepsTaken.append("offline")
        }
        .then("pay with cash instead") {
            stepsTaken.append("pay-cash")
        }

        #expect(stepsTaken == ["queue", "order", "prepare-digital-payment", "offline", "pay-cash"])
    }

    @Test("Auxiliary configuration step 'with' supplies parallel context")
    func withKeywordSuppliesContext() {
        var contextItems: [String] = []

        given("two fresh apples in a basket") {
            contextItems.append("two apples")
        }
        .with("one green granny smith and one red gala apple") {
            contextItems.append("one green, one red")
        }
        .when("eating the green apple") {
            contextItems.append("ate green")
        }
        .then("only the red apple remains") {
            contextItems.append("one red remaining")
        }

        #expect(contextItems.count == 4)
        #expect(contextItems.first == "two apples")
        #expect(contextItems.last == "one red remaining")
    }

    @Test("Step methods without descriptions execute in identical sequence")
    func stepsWithoutDescriptionsExecuteInSequence() {
        var executed: [String] = []

        given(of: String.self) {
            executed.append("given")
            >>>"seed"
        }
        .with(of: (String, Int).self) { seed in
            executed.append("with")
            >>>seed
            >>>10
        }
        .when(of: String.self) { str, count in
            executed.append("when")
            >>>"\(str): \(count)"
        }
        .and(of: String.self) { combined in
            executed.append("and")
            >>>combined.uppercased()
        }
        .but(of: String.self) { upper in
            executed.append("but")
            >>>upper
        }
        .then(of: Void.self) { finalStr in
            executed.append("then")
            #expect(finalStr == "SEED: 10")
        }

        #expect(executed == ["given", "with", "when", "and", "but", "then"])
    }

    @Test("Step failure bypasses downstream steps in standard chain")
    func stepFailureBypassesDownstreamSteps() {
        var downstreamRan = false

        given("a failing step") {
            throw ScenarioError.diskFull
        }
        .when("attempting to process") {
            downstreamRan = true
        }
        .then("attempting to assert") {
            downstreamRan = true
        }

        #expect(downstreamRan == false)
    }

    @Test("Chaining empty or repeated steps retains pipeline validity")
    func repeatedAndEmptyStepsExecuteCorrectly() {
        let counter = 0

        given("starting counter") {
            >>>counter
        }
        .and("increment once") { c in
            >>>(c + 1)
        }
        .and("increment twice") { c in
            >>>(c + 1)
        }
        .then("counter is 2") { c in
            #expect(c == 2)
            >>>c
        }
        .then("counter still 2") { c in
            #expect(c == 2)
        }
    }
}
