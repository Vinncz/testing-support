import Foundation

/// The prefix operator that allows you to pass data between gherkin blocks.
///
/// Use `>>>` before an expression to pass its result to the next step in the chain.
///   Expressions without this operator will not be captured by the ``PassthroughBuilder``.
prefix operator >>>

/// Wraps a value to be captured by the ``PassthroughBuilder``.
///
/// You may initialize a passthrough value directly, but it's often better and more concise to use the `>>>` operator.
public struct PassthroughValue<T> {
    let value: T
}

/// Wraps a given value inside a ``PassthroughValue``.
///
/// ## Usage
/// ```swift
/// let foo: String = "foo"
/// let bar: PassthroughValue<String> = >>>foo
///
/// // applicable to tuples too
/// let foo: String = "foo"
/// let bar: String = "bar"
/// let foobar: PassthroughValue<(String, String)> = >>>(foo, bar)
/// ```
public prefix func >>> <T>(value: T) -> PassthroughValue<T> {
    PassthroughValue(value: value)
}
