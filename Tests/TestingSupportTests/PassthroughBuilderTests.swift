import Foundation
import Testing
@testable import TestingSupport

/// The test suite verifying 6 cases for Passthrough Builder & Value Wrapping.
///   There are 4 positives, 1 negatives, and 1 edge/uncategorized cases.
///
/// (+) PassthroughValue wraps and unwraps values directly and via >>> operator
/// (+) Discarded expressions within builder blocks are ignored
/// (+) Partial blocks accumulate values and properly ignore leading or trailing void statements
/// (+) Result builder supports all tuple sizes from 2 up to 9 elements
/// (-) Builder gracefully propagates errors thrown before accumulation completes
/// (?) Empty block evaluates to Void without error
@Suite("Passthrough Builder & Value Wrapping", .tags(.dataFlow))
struct PassthroughBuilderTests {

    @Test("PassthroughValue wraps and unwraps values directly and via >>> operator")
    func directPassthroughValueWrapping() {
        let value = "hello"
        let wrapped = >>>value
        #expect(wrapped.value == "hello")

        let directWrapped = PassthroughValue(value: 123)
        #expect(directWrapped.value == 123)
    }

    @Test("Discarded expressions within builder blocks are ignored")
    func discardedExpressionsInBuilder() {
        given("builder block with void expressions") {
            let _ = "ignored string"
            ()
            >>>42
            ()
        }
        .then("only the passthrough value is kept") { val in
            #expect(val == 42)
        }
    }

    @Test("Partial blocks accumulate values and properly ignore leading or trailing void statements")
    func partialBlocksWithVoidAccumulation() {
        
        // Void first, then PassthroughValue
        let val1: Void = PassthroughBuilder.buildPartialBlock(first: ())
        let res1 = PassthroughBuilder.buildPartialBlock(accumulated: val1, next: >>>"first-val")
        #expect(res1 == "first-val")

        // PassthroughValue first, then Void
        let firstWrapped = PassthroughBuilder.buildPartialBlock(first: >>>100)
        let res2 = PassthroughBuilder.buildPartialBlock(accumulated: firstWrapped, next: ())
        #expect(res2 == 100)

        // Void first, then Void
        let res3: Void = PassthroughBuilder.buildPartialBlock(accumulated: (), next: ())
        #expect(res3 == ())

        // buildExpression for Void and general T
        PassthroughBuilder.buildExpression(())
        PassthroughBuilder.buildExpression("ignored")
    }

    @Test("Result builder supports all tuple sizes from 2 up to 9 elements")
    func tupleAccumulationOverloads() {

        // 2-tuple + 1 -> 3-tuple
        let t3 = PassthroughBuilder.buildPartialBlock(accumulated: (1, 2), next: >>>3)
        #expect(t3.0 == 1 && t3.1 == 2 && t3.2 == 3)

        // 3-tuple + 1 -> 4-tuple
        let t4 = PassthroughBuilder.buildPartialBlock(accumulated: t3, next: >>>4)
        #expect(t4.0 == 1 && t4.1 == 2 && t4.2 == 3 && t4.3 == 4)

        // 4-tuple + 1 -> 5-tuple
        let t5 = PassthroughBuilder.buildPartialBlock(accumulated: t4, next: >>>5)
        #expect(t5.0 == 1 && t5.1 == 2 && t5.2 == 3 && t5.3 == 4 && t5.4 == 5)

        // 5-tuple + 1 -> 6-tuple
        let t6 = PassthroughBuilder.buildPartialBlock(accumulated: t5, next: >>>6)
        #expect(t6.0 == 1 && t6.1 == 2 && t6.2 == 3 && t6.3 == 4 && t6.4 == 5 && t6.5 == 6)

        // 6-tuple + 1 -> 7-tuple
        let t7 = PassthroughBuilder.buildPartialBlock(accumulated: t6, next: >>>7)
        #expect(t7.0 == 1 && t7.1 == 2 && t7.2 == 3 && t7.3 == 4 && t7.4 == 5 && t7.5 == 6 && t7.6 == 7)

        // 7-tuple + 1 -> 8-tuple
        let t8 = PassthroughBuilder.buildPartialBlock(accumulated: t7, next: >>>8)
        #expect(t8.0 == 1 && t8.1 == 2 && t8.2 == 3 && t8.3 == 4 && t8.4 == 5 && t8.5 == 6 && t8.6 == 7 && t8.7 == 8)

        // 8-tuple + 1 -> 9-tuple
        let t9 = PassthroughBuilder.buildPartialBlock(accumulated: t8, next: >>>9)
        #expect(
            t9.0 == 1 && t9.1 == 2 && t9.2 == 3 && t9.3 == 4 && t9.4 == 5 && t9.5 == 6 && t9.6 == 7 && t9.7 == 8 && t9.8 == 9
        )
    }

    @Test("Builder gracefully propagates errors thrown before accumulation completes")
    func builderPropagatesErrors() {
        var caught = false
        do {
            try given("throwing block", of: (Int, Int).self) {
                >>>1
                throw ScenarioError.diskFull
                >>>2
            }
            .finally {}
        } catch {
            caught = true
            #expect(error as? ScenarioError == .diskFull)
        }
        #expect(caught == true)
    }

    @Test("Empty block evaluates to Void without error")
    func emptyBlockEvaluation() {
        let emptyResult: Void = PassthroughBuilder.buildBlock()
        #expect(emptyResult == ())
    }
}
