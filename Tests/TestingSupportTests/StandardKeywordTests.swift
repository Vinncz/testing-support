import Foundation
import Testing
@testable import TestingSupport

@Suite("Standard Gherkin Keywords", .tags(.standardKeywords))
struct StandardKeywordTests {

    @Test("Standard Gherkin keyword chain executes in sequential order")
    func standardKeywordChainExecutesInSequence() async {
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

    @Test("Additive and contrasting keywords execute in sequence")
    func additiveAndContrastingKeywordsExecuteInSequence() async {
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
    func multipleActionStepsExecuteInSequence() async {
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
    func withKeywordSuppliesContext() async {
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
}
