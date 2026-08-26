import Foundation

/// Asynchronous implementation of the standard Gherkin keyword that enables fluent chaining.
extension GherkinStep {

    /// Sister variant of the synchronous `and(_:work:)`. It chains a supporting step to the scenario;
    ///   maintaining the current flow while modifying or verifying the context.
    ///
    /// Use `.and(...)` to add additional context or setup requirements
    ///   that are not the primary action of the test.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step (ignored by the compiler).
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func and<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Sister variant of the synchronous `but(_:work:)`. It chains a negation step to the scenario;
    ///   often used to verify negative assertions or inverse conditions.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step.
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func but<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Sister variant of the synchronous `when(_:work:)`. It chains the primary action step;
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
    public func when<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Sister variant of the synchronous `then(_:work:)`. It chains the assertion step;
    ///   used to verify that the previous action produced the expected results.
    ///
    /// - Parameters:
    ///   - _: A human-readable description of the step.
    ///   - work: The closure to execute, supporting ``PassthroughBuilder``.
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func then<U>(_: String? = nil, work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }
}

/// Asynchronous syntactic sugar extension that is not part of standard Gherkin syntax.
extension GherkinStep {

    /// Sister variant to the synchronous `after(_:work:)`.
    ///   It chains a temporal step that occurs subsequent to the action;
    ///   useful for verifying delayed side effects or async states.
    ///
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func after<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Sister variant to the synchronous `should(_:work:)`.
    ///   It chains a conditional assertion step;
    ///   implying a requirement that must be met for the test to pass.
    ///
    /// - Returns: The result of the work closure, wrapped in a new instance of ``GherkinStep`` for chaining.
    @discardableResult
    public func should<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }
}

/// Helper extension.
extension GherkinStep {

    private func asynchronousFlatMap<U>(_ transform: (T) async throws -> U) async -> GherkinStep<U> {
        switch result {
        case .success(let value):
            do {
                let transformed = try await transform(value)
                return GherkinStep<U>(result: .success(transformed))
            } catch {
                return GherkinStep<U>(result: .failure(error))
            }
        case .failure(let error):
            return GherkinStep<U>(result: .failure(error))
        }
    }
}
