import Foundation

/// A result builder that constructs tuples from values marked with `>>>`.
///
/// Any expression not marked with `>>>` is executed but ignored in the return value.
@resultBuilder
public struct PassthroughBuilder {}

/// Declaration functionality extension.
extension PassthroughBuilder {

    /// Captures a marked value for inclusion in the final result.
    ///
    /// - Parameter expression: The `PassthroughValue` to be captured.
    /// - Returns: The same `PassthroughValue`, ready for accumulation.
    public static func buildExpression<T>(_ expression: PassthroughValue<T>) -> PassthroughValue<T> { expression }

    /// Ignores an unmarked value within the builder block.
    ///
    /// - Parameter expression: A value that should be discarded.
    public static func buildExpression<T>(_ expression: T) {}

    /// Ignores a void expression within the builder block.
    ///
    /// - Parameter expression: A void expression (e.g., a function call with no return value).
    public static func buildExpression(_ expression: Void) {}

    /// Defines the result for an empty block.
    public static func buildBlock() {}
}

/// Accumulation extension.
extension PassthroughBuilder {

    /// Captures the first marked value encountered in the block.
    ///
    /// - Parameter first: The first valid `PassthroughValue`.
    /// - Returns: The underlying value of type `T`.
    public static func buildPartialBlock<T>(first: PassthroughValue<T>) -> T { first.value }

    /// Handles a block that starts with a void or ignored expression.
    ///
    /// - Parameter first: A void input.
    public static func buildPartialBlock(first: Void) {}

    /// Accumulates a new marked value into an existing result.
    ///
    /// - Parameters:
    ///   - accumulated: The previously captured value(s).
    ///   - next: The next `PassthroughValue` to capture.
    /// - Returns: A tuple containing the accumulated value(s) and the new value.
    public static func buildPartialBlock<T, U>(accumulated: T, next: PassthroughValue<U>) -> (T, U) {
        (accumulated, next.value)
    }

    /// Carries forward the accumulated result when encountering an ignored expression.
    ///
    /// - Parameters:
    ///   - accumulated: The already captured value(s).
    ///   - next: An ignored void expression.
    /// - Returns: The original accumulated value(s).
    public static func buildPartialBlock<T>(accumulated: T, next: Void) -> T { accumulated }

    /// Discards accumulated voids and captures the first valid value encountered later in the block.
    ///
    /// - Parameters:
    ///   - accumulated: Previous void expressions.
    ///   - next: The first `PassthroughValue` encountered.
    /// - Returns: The underlying value of type `U`.
    public static func buildPartialBlock<U>(accumulated: Void, next: PassthroughValue<U>) -> U { next.value }

    /// Continues to ignore input when both the accumulated state and the next expression are void.
    ///
    /// - Parameters:
    ///   - accumulated: Previous void expressions.
    ///   - next: A new void expression.
    public static func buildPartialBlock(accumulated: Void, next: Void) {}
}

/// Flattening extension.
extension PassthroughBuilder {

    /// Combines an accumulated 2-tuple with the next captured value into a 3-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 2-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: A 3-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3>(
        accumulated: (T1, T2),
        next: PassthroughValue<T3>
    ) -> (T1, T2, T3) {
        (accumulated.0, accumulated.1, next.value)
    }

    /// Combines an accumulated 3-tuple with the next captured value into a 4-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 3-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: A 4-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3, T4>(
        accumulated: (T1, T2, T3),
        next: PassthroughValue<T4>
    ) -> (T1, T2, T3, T4) {
        (accumulated.0, accumulated.1, accumulated.2, next.value)
    }

    /// Combines an accumulated 4-tuple with the next captured value into a 5-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 4-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: A 5-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3, T4, T5>(
        accumulated: (T1, T2, T3, T4),
        next: PassthroughValue<T5>
    ) -> (T1, T2, T3, T4, T5) {
        (accumulated.0, accumulated.1, accumulated.2, accumulated.3, next.value)
    }

    /// Combines an accumulated 5-tuple with the next captured value into a 6-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 5-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: A 6-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3, T4, T5, T6>(
        accumulated: (T1, T2, T3, T4, T5),
        next: PassthroughValue<T6>
    ) -> (T1, T2, T3, T4, T5, T6) {
        (accumulated.0, accumulated.1, accumulated.2, accumulated.3, accumulated.4, next.value)
    }

    /// Combines an accumulated 6-tuple with the next captured value into a 7-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 6-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: A 7-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3, T4, T5, T6, T7>(
        accumulated: (T1, T2, T3, T4, T5, T6),
        next: PassthroughValue<T7>
    ) -> (T1, T2, T3, T4, T5, T6, T7) {
        (accumulated.0, accumulated.1, accumulated.2, accumulated.3, accumulated.4, accumulated.5, next.value)
    }

    /// Combines an accumulated 7-tuple with the next captured value into an 8-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 7-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: An 8-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3, T4, T5, T6, T7, T8>(
        accumulated: (T1, T2, T3, T4, T5, T6, T7),
        next: PassthroughValue<T8>
    ) -> (T1, T2, T3, T4, T5, T6, T7, T8) {
        (
            accumulated.0, accumulated.1, accumulated.2, accumulated.3, accumulated.4, accumulated.5, accumulated.6,
            next.value
        )
    }

    /// Combines an accumulated 8-tuple with the next captured value into a 9-tuple.
    ///
    /// - Parameters:
    ///   - accumulated: The previously accumulated 8-tuple of values.
    ///   - next: The next captured `PassthroughValue`.
    /// - Returns: A 9-tuple containing all accumulated values and the next value.
    public static func buildPartialBlock<T1, T2, T3, T4, T5, T6, T7, T8, T9>(
        accumulated: (T1, T2, T3, T4, T5, T6, T7, T8),
        next: PassthroughValue<T9>
    ) -> (T1, T2, T3, T4, T5, T6, T7, T8, T9) {
        (
            accumulated.0, accumulated.1, accumulated.2, accumulated.3, accumulated.4, accumulated.5, accumulated.6,
            accumulated.7, next.value
        )
    }
}
