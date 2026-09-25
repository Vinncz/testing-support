extension GherkinStep {

    /// Chains an auxiliary configuration or contextual dependency to the scenario.
    ///
    /// Use `with` to supply supplementary parameters, environment configurations, or
    ///   auxiliary dependencies alongside existing state.
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func with<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains an auxiliary configuration step with an explicit output type anchor.
    @discardableResult
    public func with<U>(_: String? = nil, of type: U.Type, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains an auxiliary configuration step with an explicit output type anchor without a description.
    @discardableResult
    public func with<U>(of type: U.Type, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        with(nil, of: type, work: work)
    }
}
