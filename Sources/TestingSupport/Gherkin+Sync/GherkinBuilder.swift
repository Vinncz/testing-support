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

/// Starts a BDD-style test scenario with an explicit expected output type anchor.
///
/// Anchoring the type explicitly allows the Swift compiler to infer the exact type
///   of downstream step closure parameters even if errors or typos exist inside chained blocks.
///
/// - Parameters:
///   - _: An optional description of the scenario.
///   - type: The explicit type produced by the setup block.
///   - work: A closure that yields data of type `T` using the `>>>` operator.
/// - Returns: A `GherkinStep` containing the result.
@discardableResult
public func given<T>(_: String? = nil, of type: T.Type, @PassthroughBuilder work: () throws -> T) -> GherkinStep<T> {
    do {
        return GherkinStep<T>(result: .success(try work()))
    } catch {
        return GherkinStep<T>(result: .failure(error))
    }
}

/// Starts a BDD-style test scenario with an explicit expected output type anchor without a description.
///
/// - Parameters:
///   - type: The explicit type produced by the setup block.
///   - work: A closure that yields data of type `T` using the `>>>` operator.
/// - Returns: A `GherkinStep` containing the result.
@discardableResult
public func given<T>(of type: T.Type, @PassthroughBuilder work: () throws -> T) -> GherkinStep<T> {
    given(nil, of: type, work: work)
}

/// Starts a BDD-style test scenario directly with an explicit initial value.
///
/// Bypasses the result builder closure entirely, guaranteeing immediate concrete type inference
///   for all downstream step parameters without closure typing overhead.
///
/// - Parameters:
///   - _: An optional description of the scenario.
///   - value: The initial value to inject into the pipeline.
/// - Returns: A `GherkinStep` containing the value.
@discardableResult
public func given<T>(_: String? = nil, value: T) -> GherkinStep<T> {
    GherkinStep<T>(result: .success(value))
}

/// Starts a BDD-style test scenario directly with an explicit initial value without a description.
///
/// - Parameter value: The initial value to inject into the pipeline.
/// - Returns: A `GherkinStep` containing the value.
@discardableResult
public func given<T>(value: T) -> GherkinStep<T> {
    given(nil, value: value)
}

/// Starts a BDD-style test scenario directly with a pre-existing value.
///
/// Bypasses the result builder closure entirely, guaranteeing immediate concrete type inference
///   for all downstream step parameters without closure typing overhead.
///
/// - Parameters:
///   - _: An optional description of the scenario.
///   - initialValue: The initial value to inject into the pipeline.
/// - Returns: A `GherkinStep` containing the value.
@discardableResult
public func given<T>(_: String? = nil, _ initialValue: T) -> GherkinStep<T> {
    GherkinStep<T>(result: .success(initialValue))
}

/// Starts a BDD-style test scenario directly with a pre-existing value without a description.
///
/// - Parameter initialValue: The initial value to inject into the pipeline.
/// - Returns: A `GherkinStep` containing the value.
@discardableResult
public func given<T>(_ initialValue: T) -> GherkinStep<T> {
    given(nil, initialValue)
}
