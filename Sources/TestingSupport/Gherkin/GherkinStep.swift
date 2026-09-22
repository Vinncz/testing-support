import Foundation

/// A stateful container that carries context and manages execution flow across steps in a BDD scenario.
///
/// `GherkinStep` is a pipeline wrapper around a standard `Result<T, Error>`.
///   As each step in a scenario executes, it receives the accumulated value produced by the preceding step,
///   transforms or asserts on that value, and passes the new state downstream.
///
/// ### Overview
/// Scenarios begin with ``given(_:work:)`` and chain additional steps using standard BDD keywords
///   (``when(_:work:)``, ``then(_:work:)``, ``and(_:work:)``, ``with(_:work:)``, ``but(_:work:)``) or temporal and
///   assertion extensions (``after(_:work:)``, ``should(_:work:)``).
///
/// Steps use ``PassthroughBuilder``, allowing you to pass values forward either by explicitly returning a value or
///   by marking expressions with the prefix ``>>>(_:)`` operator:
///
/// ```swift
/// try given("an unauthenticated user and an auth service") {
///     let service = AuthenticationService()
///     let credentials = Credentials(username: "blob", password: "password-123")
///     >>>service
///     >>>credentials
/// }
/// .when("the user logs in with valid credentials") { service, credentials in
///     try service.authenticate(using: credentials)
/// }
/// .then("a valid session token is issued") { session in
///     #expect(session.isValid)
/// }
/// .finally("tear down local credentials") {
///     Keychain.reset()
/// }
/// ```
///
/// ### Short-Circuiting and Error Propagation
/// If any step closure throws an error, execution immediately short-circuits. All subsequent steps in the chain
///   are bypassed without executing their closures, preserving the original error inside the `GherkinStep`.
///
/// The ``finally(_:work:)`` block is guaranteed to execute regardless of whether earlier steps succeeded or failed.
///   Once its cleanup work finishes, `finally` rethrows the upstream error to fail the enclosing test case, or returns
///   the final accumulated value if all steps succeeded.
public struct GherkinStep<T> {

    /// The current state of the step pipeline, containing either the accumulated output value or the error that
    ///   short-circuited the scenario.
    let result: Result<T, Error>
}

// MARK: - Standard Keywords

/// Methods for chaining standard Gherkin steps in a scenario.
extension GherkinStep {

    /// Chains an additive step that continues the current scenario context.
    ///
    /// Use `and` to append secondary setup, extra preconditions, actions, or assertions following a preceding step
    ///   without repeating that step's keyword.
    ///
    /// ```swift
    /// given("a registered user") {
    ///     User(id: 1, name: "Blob")
    /// }
    /// .and("an empty shopping cart") { user in
    ///     let cart = ShoppingCart(userID: user.id)
    ///     >>>user
    ///     >>>cart
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func and<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains an auxiliary configuration or contextual dependency to the scenario.
    ///
    /// Use `with` to supply supplementary parameters, environment configurations, or
    ///   auxiliary dependencies alongside existing state.
    ///
    /// ```swift
    /// given("a checkout order") {
    ///     Order(total: 100)
    /// }
    /// .with("a VIP customer discount coupon applied") { order in
    ///     let coupon = Coupon(code: "VIP20", discountPercentage: 0.20)
    ///     >>>order
    ///     >>>coupon
    /// }
    /// .when("calculating the discounted final invoice") { order, coupon in
    ///     order.applying(coupon)
    /// }
    /// .then("the final price reflects the discount") { invoice in
    ///     #expect(invoice.amountDue == 80)
    /// }
    /// ```
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

    /// Chains an exclusionary or negative assertion step to the scenario.
    ///
    /// Use `but` to assert inverse conditions, verify that a side effect did not happen,
    ///   or introduce contrasting constraints against a previously asserted outcome.
    ///
    /// ```swift
    /// given("an active user account") {
    ///     UserAccount(balance: 50, isSuspended: false)
    /// }
    /// .when("requesting a withdrawal exceeding the current balance") { account in
    ///     account.withdraw(amount: 100)
    /// }
    /// .then("the transaction fails with insufficient funds") { result in
    ///     #expect(result.status == .rejected)
    ///     >>>result
    /// }
    /// .but("the account balance remains untouched") { result in
    ///     #expect(result.account.balance == 50)
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func but<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains the primary action step that triggers the behavior under test.
    ///
    /// Use `when` to execute the core operation, user interaction, or system event that transitions the scenario
    ///   from its initial preconditions to its observable outcome.
    ///
    /// ```swift
    /// given("an authenticated payment client and an active invoice") {
    ///     let client = PaymentClient.mock()
    ///     let invoice = Invoice(id: "inv-001", amount: 42.0)
    ///     >>>client
    ///     >>>invoice
    /// }
    /// .when("the client submits the payment transaction") { client, invoice in
    ///     try client.charge(invoice: invoice)
    /// }
    /// .then("a confirmation receipt is generated") { receipt in
    ///     #expect(receipt.isPaid)
    /// }
    /// ```
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

    /// Chains the outcome verification step that asserts expected state changes.
    ///
    /// Use `then` to observe and validate the results produced by the preceding `when` action,
    ///   ensuring all post-conditions, return values, or database mutations meet expectations.
    ///
    /// ```swift
    /// given("a user registration form") {
    ///     RegistrationForm(email: "blob@vinapp.id", password: "validPassword123")
    /// }
    /// .when("the form is submitted") { form in
    ///     try form.submit()
    /// }
    /// .then("a new user profile should be created with the given email") { profile in
    ///     #expect(profile.email == "blob@vinapp.id")
    ///     #expect(profile.isVerified == false)
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func then<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }
}

// MARK: - Extended Keywords

/// Extended step keywords for temporal observation and contract validation.
extension GherkinStep {

    /// Chains a temporal step that inspects state or side effects after the primary action completes.
    ///
    /// Use `after` to perform delayed validations, observe background asynchronous side effects,
    ///   or inspect secondary telemetry emitted following the execution of `when`.
    ///
    /// ```swift
    /// given("an analytics service tracking screen visits") {
    ///     AnalyticsClient.mock()
    /// }
    /// .when("the user opens the settings screen") { client in
    ///     client.trackScreen("settings")
    ///     >>>client
    /// }
    /// .after("the event is batched and flushed to storage") { client in
    ///     #expect(client.flushedEvents.contains("settings"))
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func after<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }

    /// Chains a conditional assertion step that verifies invariants and requirements.
    ///
    /// Use `should` to explicitly assert prerequisites or invariant contracts that must hold true before proceeding
    ///   further down the scenario chain.
    ///
    /// ```swift
    /// given("a fetched network payload") {
    ///     try fetchRemoteConfig()
    /// }
    /// .should("contain a valid feature flags dictionary") { config in
    ///     guard !config.featureFlags.isEmpty else {
    ///         throw ConfigurationError.missingFlags
    ///     }
    ///     return config
    /// }
    /// .then("load features according to the configuration") { config in
    ///     #expect(config.isFeatureEnabled("newCheckout"))
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: A closure receiving the output of the previous step. Marked with ``PassthroughBuilder`` to support
    ///     passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func should<U>(_: String? = nil, @PassthroughBuilder work: (T) throws -> U) -> GherkinStep<U> {
        flatMap(work)
    }
}

// MARK: - Teardown

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
    /// ```swift
    /// try given("a temporary database file on disk") {
    ///     try TestDatabase.create(at: tempURL)
    /// }
    /// .when("inserting records into the database") { db in
    ///     try db.insert(User(id: 1, name: "Blob"))
    ///     return db
    /// }
    /// .then("the record count matches") { db in
    ///     #expect(db.count == 1)
    /// }
    /// .finally("remove the temporary database file") {
    ///     try? FileManager.default.removeItem(at: tempURL)
    /// }
    /// ```
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

// MARK: - Private Helpers

extension GherkinStep {

    /// Evaluates the transformation closure if the current step succeeded, or propagates an existing failure.
    ///
    /// - Parameter transform: The throwing transformation closure to execute on the payload `T`.
    /// - Returns: A new `GherkinStep` holding either the transformed value of type `U` or the caught error.
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
