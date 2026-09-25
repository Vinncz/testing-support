extension GherkinStep {

    /// Chains a conditional assertion step that asynchronously verifies invariants and requirements.
    ///
    /// Use `should` to explicitly assert prerequisites or invariant contracts that must hold true before proceeding
    ///   further down the scenario chain.
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func should<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains a conditional assertion step asynchronously with an explicit output type anchor.
    @discardableResult
    public func should<U>(
        _: String? = nil,
        of type: U.Type,
        @PassthroughBuilder work: (T) async throws -> U
    ) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains a conditional assertion step asynchronously with an explicit output type anchor without a description.
    @discardableResult
    public func should<U>(of type: U.Type, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await should(nil, of: type, work: work)
    }
}
