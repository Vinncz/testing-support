import Foundation

/// A stateful container that carries context and manages execution flow across steps in a BDD scenario.
///
/// `GherkinStep` is a pipeline wrapper around a standard `Result<T, Error>`.
///   As each step in a scenario executes, it receives the accumulated value produced by the preceding step,
///   transforms or asserts on that value, and passes the new state downstream.
///
/// Steps use ``PassthroughBuilder``, allowing you to pass values forward either by explicitly returning a value or
///   by marking expressions with the prefix ``>>>(_:)`` operator.
///
/// If any step closure throws an error, execution immediately short-circuits. All subsequent steps in the chain
///   are bypassed without executing their closures, preserving the original error inside the `GherkinStep`.
///
/// The `finally` block is guaranteed to execute regardless of whether earlier steps succeeded or failed.
///   Once its cleanup work finishes, `finally` rethrows the upstream error to fail the enclosing test case, or returns
///   the final accumulated value if all steps succeeded.
public struct GherkinStep<T> {

    /// The current state of the step pipeline, containing either the accumulated output value or the error that
    ///   short-circuited the scenario.
    let result: Result<T, Error>
}

extension GherkinStep {

    /// Evaluates the transformation closure if the current step succeeded, or propagates an existing failure.
    ///
    /// - Parameter transform: The throwing transformation closure to execute on the payload `T`.
    /// - Returns: A new `GherkinStep` holding either the transformed value of type `U` or the caught error.
    func flatMap<U>(_ transform: (T) throws -> U) -> GherkinStep<U> {
        switch result {
        case .success(let value):
            do {
                return GherkinStep<U>(result: .success(try transform(value)))
            } catch {
                return GherkinStep<U>(result: .failure(error))
            }
        case .failure(let error):
            return GherkinStep<U>(result: .failure(error))
        }
    }
}
