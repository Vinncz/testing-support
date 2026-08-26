import Foundation

/// Starts a BDD-style test scenario.
///
/// Executes the setup block and wraps the result into a ``GherkinStep`` to begin the chain.
///
/// - Parameters:
///   - _: A description of the scenario.
///   - work: A closure that yields data using the `>>>` operator.
/// - Returns: A `GherkinStep` containing the result.
@discardableResult
public func given<T>(_: String? = nil, @PassthroughBuilder work: () throws -> T) -> GherkinStep<T> {
    do {
        return GherkinStep<T>(result: .success(try work()))
    } catch {
        return GherkinStep<T>(result: .failure(error))
    }
}
