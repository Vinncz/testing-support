import Foundation

/// The prefix operator that allows you to pass data between gherkin blocks.
///
/// Use `>>>` before an expression to pass its result to the next step in the chain.
///   Expressions without this operator are executed as side effects,
///   but are ignored by the ``PassthroughBuilder``.
/// ```
prefix operator >>>

/// Wraps a value to be captured by the ``PassthroughBuilder``.
///
/// You may initialize a passthrough value directly,
///   but it's often better and more concise to use the `>>>` operator.
public struct PassthroughValue<T> {
    let value: T
}

/// Marks a value to be passed onto the next ``GherkinStep``.
///
/// Expressions marked with this operator are collected into a tuple.
/// Unmarked expressions are treated as side effects.
public prefix func >>> <T>(value: T) -> PassthroughValue<T> {
    PassthroughValue(value: value)
}
