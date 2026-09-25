extension GherkinStep {

    /// Chains the primary action step that triggers the behavior under test.
    ///
    /// Use `when` to execute the core operation, user interaction, or system event that transitions the scenario
    ///   from its initial preconditions to its observable outcome.
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func when<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains the primary action step with an explicit output type anchor.
    @discardableResult
    public func when<U>(_: String? = nil, of type: U.Type, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains the primary action step with an explicit output type anchor without a description.
    @discardableResult
    public func when<U>(of type: U.Type, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        when(nil, of: type, work: work)
    }
}
