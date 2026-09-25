extension GherkinStep {

    /// Chains an exclusionary or negative assertion step asynchronously to the scenario.
    ///
    /// Use `but` to assert inverse conditions, verify that a side effect did not happen,
    ///   or introduce contrasting constraints against a previously asserted outcome.
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func but<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains an exclusionary or negative assertion step asynchronously with an explicit output type anchor.
    @discardableResult
    public func but<U>(_: String? = nil, of type: U.Type, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains an exclusionary or negative assertion step asynchronously with an explicit output type anchor without a description.
    @discardableResult
    public func but<U>(of type: U.Type, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await but(nil, of: type, work: work)
    }
}
