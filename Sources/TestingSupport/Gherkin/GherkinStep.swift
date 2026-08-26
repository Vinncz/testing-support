import Foundation

/// A container representing the current state of a BDD test scenario.
///
/// This struct manages the flow of data and errors. If a step fails, subsequent
/// steps are skipped until `.finally` is reached.
public struct GherkinStep<T> {

    /// The internal result holding the passed value or the stopping error
    let result: Result<T, Error>
}

/// Synchronous implementation of the standard Gherkin keyword that enables fluent chaining.
extension GherkinStep {

    /// Chains a supporting step to the scenario;
    ///   maintaining the current flow while modifying or verifying the context.
    ///
    /// Use `.and(...)` to add additional context or setup requirements
    ///   that are not the primary action of the test.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step that does not affect the execution of the step.
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func and<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains a negation step to the scenario;
    ///   often used to verify negative assertions or inverse conditions.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step.
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func but<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains the primary action step;
    ///   where the main logic under test is usually executed.
    ///
    /// Use `.when(...)` to represent the specific behavior or event
    ///   that triggers the state change being tested.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step.
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func when<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains the assertion step;
    ///   used to verify that the previous action produced the expected results.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step.
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func then<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }
}

/// Syntactic sugar extension that is not part of standard Gherkin syntax.
extension GherkinStep {

    /// Chains a temporal step that occurs subsequent to the action;
    ///   useful for verifying delayed side effects or async states.
    ///
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func after<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains a conditional assertion step;
    ///   implying a requirement that must be met for the test to pass.
    ///
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func should<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }
}

/// Functional extension to clean up the chain.
extension GherkinStep {

    /// Terminates the chain and executes cleanup code.
    ///
    /// This block always runs, even if previous steps failed.
    /// - Throws: The first error encountered in the chain, if any.
    /// - Returns: The final value produced by the last step in the chain.
    @discardableResult
    public func finally(_: String? = nil, work: () -> Void) throws -> T {
        work()
        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}

/// Helper extension.
extension GherkinStep {

    private func flatMap<U>(_ transform: (T) throws -> U) -> GherkinStep<U> {
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
