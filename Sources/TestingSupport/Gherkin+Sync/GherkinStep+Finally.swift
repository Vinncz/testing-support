/// Terminal cleanup operations for scenario execution.
extension GherkinStep {

    /// Terminates the scenario chain, executing mandatory cleanup and rethrowing any pipeline errors.
    ///
    /// The provided `work` closure is unconditionally executed — even if an earlier step in the chain threw an error
    ///   and short-circuited subsequent steps.
    ///
    /// Once `work` completes:
    ///   - If any upstream step threw an error, that error is rethrown out of `finally`
    ///     so the test runner detects the failure.
    ///   - If all steps succeeded, the final accumulated value of type `T` is returned.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the cleanup step.
    ///   - work: A closure containing teardown logic that must run regardless of scenario outcome.
    /// - Returns: The final value produced by the last executed step in the chain.
    /// - Throws: The first error encountered during scenario execution, if any.
    @discardableResult
    public func finally(_: String? = nil, work: () -> Void) throws -> T {
        work()
        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}
