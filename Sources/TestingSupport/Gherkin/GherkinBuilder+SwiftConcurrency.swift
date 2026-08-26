import Foundation

/// Starts a BDD-style test scenario with a asynchronous setup block.
///
/// Executes the setup block and wraps the result into a ``GherkinStep`` to begin the chain.
///
/// - Parameters:
///   - _: A description of the scenario.
///   - work: A closure that yields data using the `>>>` operator.
/// - Returns: A `GherkinStep` containing the result.
@discardableResult
public func given<T>(_: String? = nil, @PassthroughBuilder work: () async throws -> T) async -> GherkinStep<T> {
    do {
        return GherkinStep<T>(result: .success(try await work()))
    } catch {
        return GherkinStep<T>(result: .failure(error))
    }
}
