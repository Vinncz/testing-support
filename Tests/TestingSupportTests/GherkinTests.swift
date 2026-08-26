import Foundation
import OSLog
import Testing

@testable import TestingSupport

struct GherkinTests {

    /// The namespace that test the usage of standard gherkin keywords.
    ///
    /// This suite doesn't focus on runtime behavior as much-
    ///   as how it Red-Green light'd the development of the Gherkin syntax.
    /// Its goal is to make sure Gherkin could be expessed clearly
    ///   and intuitively by writing readable cases.
    ///
    /// For best experience, fold all the methods in this suite [⌥ ⌘ ⇧ ←].
    struct StandardGherkinKeywordTests {

        @Test
        func `chain of standard gherkin keyword should execute in sequence`() async {
            var logMessage: String = ""

            given("heavy rain befall Greater Jakarta") {
                logMessage += "brrr, it's raining~\n"
            }
            .when("it doesn't stop within 2 hours") {
                logMessage += "(time flies..) it hasn't stopped yet?\n"
            }
            .then("expect the office to be empty") {
                logMessage += "(one struggle to the office later..) there's nobody here!\n"
            }

            Logger.testing.info("\(logMessage)")
        }

        @Test
        func `chain of additive standard gherkin keyword should execute in sequence`() async {
            var logMessage: String = ""

            given("a difficult math problem") {
                logMessage += "What's 9 + 10?\n"
            }
            .but("my mind is distracted") {
                logMessage += "~life could be dream~\n"
            }
            .when("i was asked to answer the question") {
                logMessage += "(Teacher, menacingly) the kid in the back!\n"
            }
            .then("i answer with 11") {
                logMessage += "The answer is 11!\n"
            }
            .and("i got ridiculed") {
                logMessage += "womp~ womp~\n"
            }

            Logger.testing.info("\(logMessage)")
        }

        @Test
        func `chain of multi-action (multiple then) standard gherkin syntax should be possible`() async {
            var logMessage: String = ""

            given("i queue at a foodcourt") {
                logMessage += "Order ready for number 44; Next!\n"
            }
            .when("i order a curry") {
                logMessage += "One curry to go.\n"
            }
            .then("i should pull out my phone and pay with it") {
                logMessage += "Yeah, qris please.\n"
            }
            .but("there's no internet") {
                logMessage += "There's no internet, do you take cash?\n"
            }
            .then("i was forced to pay with cash instead") {
                logMessage += "Keep the change.\n"
            }

            Logger.testing.info("\(logMessage)")
        }
    }

    /// The namespace that test the flow of data between gherkin blocks.
    ///
    /// This suite helped the process of Red-Green-Refactor;
    ///   in coming up with syntaxes that simplify and highlight the flow of
    ///   values between gherkin blocks.
    ///
    /// For best experience, fold all the methods in this suite [⌥ ⌘ ⇧ ←].
    struct DataFlowTests {

        @Test
        func `chain could use the return keyword to pass values onto the next block`() async {
            given("a greeting") {
                let greeting = "hello world"
                return greeting
            }
            .then("the greeting, passed via the return keyword, should be received here") { helloWorld in
                #expect(helloWorld == "hello world")
            }
        }

        @Test
        func `chain could use the >>> operator to pass values without waiting for the return keyword`() async {
            given("a greeting") {
                let greeting = "hello world"
                >>>greeting
            }
            .then("the greeting, passed via the >>> operator, should be received here") { helloWorld in
                #expect(helloWorld == "hello world")
            }
        }

        @Test
        func `chain should only pass values that are marked with >>> or return keyword`() async {
            given("a reader who is trying Gherkin blocks out") {
                >>>1
                Logger.testing.info("two")
                >>>[3...3].map(\.lowerBound)
                let four: Double = 2 * 2
                >>>four
                print("five six")
                >>>(7, 8)
            }
            .then("only values marked with >>> are passed through") {
                (one, threeInAnArray, fourAsDouble, fiveAndSixInTuple) in
                #expect(one == 1)
                #expect(threeInAnArray == [3])
                #expect(fourAsDouble == Double(4))
                #expect(fiveAndSixInTuple.0 == 7)
                #expect(fiveAndSixInTuple.1 == 8)
            }
        }

        @Test
        func `chain should explicitly re-pass values so downstream could receive them`() async {
            given("a bunch of values are declared here") {
                >>>"hello"
                "i won't be passed"
                >>>" "
                "me neither"
                >>>"world"
            }
            .after("this block intercepted them, only values tagged with >>> are carried over to the next block") {
                (hello: String, space: String, world: String) in
                >>>hello
                >>>world
            }
            .then("this block should only receive the hello and the world") { (hello: String, world: String) in
                #expect(hello == "hello")
                #expect(world == "world")
            }
        }

        @Test
        func `chain should execute the finally block, even after encountering an error`() async {
            do {
                try given("we're making a network request") {
                    Logger.testing.info("network request sent, waiting for response")
                }
                .after("the response is received") { () throws -> String in
                    throw FakeError.deserializeFailure

                    return "response"
                }
                .should("it doesn't throw no error") { (response: String) -> Void in
                    Logger.testing.info("\(response)")
                }
                .then("everything's a okay") {}
                .finally("clean up everything") {
                    Logger.testing.info("The `finally` block is executed")
                }
            } catch {
                Logger.testing.info("Handled like a glove")
            }
        }
    }

    /// The namespace that test the usage of non-standard gherkin keywords.
    ///
    /// This suite doesn't focus on runtime behavior as much-
    ///   as how it Red-Green light'd the expansion of the standard Gherkin syntax.
    /// Its goal is to make sure cases could be expessed clearly
    ///   should the standard syntax couldn't express it enough.
    ///
    /// Fold the codes in this file via [⌥ ⌘ ⇧ ←].
    struct ExtendedGherkinSyntaxTests {

        @Test
        func `chain of non-standard gherkin syntax (syntactic sugar) should behave the same as the standard`()
            async throws
        {
            try await given("a network request") {
                try await >>>performNetworkRequest()
            }
            .after("the response is received and decoded") { requestResult in
                try >>>simulateDecode(requestResult)
            }
            .should("the payload contained within is recognized and valid") { response in
                guard response != "jumbled mess" else { throw FakeError.deserializeFailure }

                return response
            }
            .then("handle them here") { response in
                #expect(response == "response")
            }
            .finally("clean up here") {}

            func simulateDecode(_: Any) throws -> String { "response" }
            func performNetworkRequest() async throws -> Result<String, FakeError> { .success("12e$P0N$3") }
        }
    }
}
