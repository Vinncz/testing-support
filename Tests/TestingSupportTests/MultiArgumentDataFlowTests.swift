import Foundation
import Testing
@testable import TestingSupport

/// The test suite verifying 7 cases for Multi-Argument & Heterogeneous Type Pipelines.
///   There are 5 positives, 1 negatives, and 1 edge/uncategorized cases.
///
/// (+) Two heterogeneous arguments pass between blocks
/// (+) Three heterogeneous arguments pass between blocks
/// (+) Heterogeneous type progression across blocks: String -> Int -> Double
/// (+) Heterogeneous type accumulation across blocks: String -> (String, Int) -> (String, Int, Double)
/// (+) Direct-value initialization with two and three arguments
/// (-) Upstream error in multi-argument pipeline prevents subsequent multi-argument evaluations
/// (?) Up to 9 distinct types pass simultaneously through result builder
@Suite("Multi-Argument & Heterogeneous Type Pipelines", .tags(.dataFlow))
struct MultiArgumentDataFlowTests {

    @Test("Two heterogeneous arguments pass between blocks")
    func twoArgumentsPassBetweenBlocks() {
        given("a user name and ID", of: (String, Int).self) {
            >>>"Blob"
            >>>101
        }
        .when("formatting a user summary badge", of: String.self) { name, id in
            >>>"\(name) (#\(id))"
        }
        .then("summary matches expected text") { summary in
            #expect(summary == "Blob (#101)")
        }
    }

    @Test("Three heterogeneous arguments pass between blocks")
    func threeArgumentsPassBetweenBlocks() {
        given("product description, quantity, and unit price", of: (String, Int, Double).self) {
            >>>"Mechanical Keyboard"
            >>>3
            >>>79.99
        }
        .when("calculating total invoice cost", of: (String, Double).self) { name, qty, price in
            let total = Double(qty) * price
            >>>name
            >>>total
        }
        .then("product and total cost are verified") { name, total in
            #expect(name == "Mechanical Keyboard")
            #expect(abs(total - 239.97) < 0.001)
        }
    }

    @Test("Heterogeneous type progression across blocks: String -> Int -> Double")
    func heterogeneousTypeProgressionAcrossBlocks() {
        given("first block yields String", of: String.self) {
            >>>"Swift Testing"
        }
        .when("second block transforms String into Int", of: Int.self) { text in
            >>>(text.count)
        }
        .then("third block transforms Int into Double", of: Double.self) { count in
            >>>(Double(count) * 1.5)
        }
        .and("all types worked out in the final assertion step") { finalDouble in
            #expect(finalDouble == 19.5)
        }
    }

    @Test("Heterogeneous type accumulation across blocks: String -> (String, Int) -> (String, Int, Double)")
    func heterogeneousTypeAccumulationAcrossBlocks() {
        given("initial step yields String", of: String.self) {
            >>>"Banana"
        }
        .when("second step accumulates an Int", of: (String, Int).self) { name in
            >>>name
            >>>42
        }
        .then("third step accumulates a Double", of: (String, Int, Double).self) { name, count in
            >>>name
            >>>count
            >>>3.14159
        }
        .and("final verification receives all accumulated types") { name, count, ratio in
            #expect(name == "Banana")
            #expect(count == 42)
            #expect(ratio == 3.14159)
        }
    }

    @Test("Direct-value initialization with two and three arguments")
    func directValueMultiArguments() {
        given("a coordinate pair", value: ("X-Axis", 100))
            .then("destructures cleanly") { axis, coordinate in
                #expect(axis == "X-Axis")
                #expect(coordinate == 100)
            }

        given("a 3D coordinate", value: ("Point", 10, 20.5))
            .then("destructures 3 values cleanly") { label, x, y in
                #expect(label == "Point")
                #expect(x == 10)
                #expect(y == 20.5)
            }
    }

    @Test("Upstream error in multi-argument pipeline prevents subsequent multi-argument evaluations")
    func multiArgumentErrorShortCircuits() {
        var reached = false

        given("initial multi-arg setup", of: (String, Int).self) {
            >>>"test"
            >>>42
        }
        .when("failing step") { (_: String, _: Int) in
            throw ScenarioError.diskFull
            >>>(1, 2)
        }
        .then("downstream step") { (_: Int, _: Int) in
            reached = true
        }

        #expect(reached == false)
    }

    @Test("Up to 9 distinct types pass simultaneously through result builder")
    func manyArgumentsPassThroughPipeline() {
        given(
            "nine distinct types marked for passthrough",
            of: (String, Int, Double, Bool, Character, Float, Int8, UInt16, String).self
        ) {
            >>>"One"
            >>>2
            >>>3.0
            >>>true
            >>>Character("E")
            >>>Float(6.5)
            >>>Int8(7)
            >>>UInt16(8)
            >>>"Nine"
        }
        .then("all nine distinct types are destructured and verified") {
            v1, v2, v3, v4, v5, v6, v7, v8, v9 in
            #expect(v1 == "One")
            #expect(v2 == 2)
            #expect(v3 == 3.0)
            #expect(v4 == true)
            #expect(v5 == Character("E"))
            #expect(v6 == Float(6.5))
            #expect(v7 == Int8(7))
            #expect(v8 == UInt16(8))
            #expect(v9 == "Nine")
        }
    }
}
