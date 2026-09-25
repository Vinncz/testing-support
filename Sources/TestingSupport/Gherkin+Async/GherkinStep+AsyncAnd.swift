extension GherkinStep {

    /// Chains an asynchronous additive step that continues the current scenario context.
    ///
    /// Use `and` to append secondary asynchronous setup, extra preconditions, actions, or assertions following
    ///   a preceding step without repeating that step's keyword.
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func and<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains an additive step asynchronously with an explicit output type anchor.
    @discardableResult
    public func and<U>(_: String? = nil, of type: U.Type, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains an additive step asynchronously with an explicit output type anchor without a description.
    @discardableResult
    public func and<U>(of type: U.Type, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await and(nil, of: type, work: work)
    }
}
