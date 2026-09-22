import Foundation

/// Asynchronous implementations of standard Gherkin keywords for fluent step chaining.
extension GherkinStep {

    /// Chains an asynchronous additive step that continues the current scenario context.
    ///
    /// Use `and` to append secondary asynchronous setup, extra preconditions, actions, or assertions following
    ///   a preceding step without repeating that step's keyword.
    ///
    /// ```swift
    /// await given("a registered user") {
    ///     User(id: 1, name: "Blob")
    /// }
    /// .and("an empty cart fetched from the remote server") { user in
    ///     let cart = try await api.fetchCart(forUserID: user.id)
    ///     >>>user
    ///     >>>cart
    /// }
    /// ```
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

    /// Chains an auxiliary configuration or contextual dependency asynchronously to the scenario.
    ///
    /// Use `with` to supply supplementary parameters, environment configurations, or auxiliary dependencies
    ///   alongside existing state.
    ///
    /// ```swift
    /// await given("a checkout order") {
    ///     Order(total: 100)
    /// }
    /// .with("a coupon fetched from the remote promotions service") { order in
    ///     let coupon = try await promoService.fetchCoupon(code: "VIP20")
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
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func with<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains an exclusionary or negative assertion step asynchronously to the scenario.
    ///
    /// Use `but` to assert inverse conditions, verify that a side effect did not happen,
    ///   or introduce contrasting constraints against a previously asserted outcome.
    ///
    /// ```swift
    /// await given("an active user account") {
    ///     UserAccount(balance: 50, isSuspended: false)
    /// }
    /// .when("requesting an asynchronous withdrawal exceeding the current balance") { account in
    ///     await account.withdraw(amount: 100)
    /// }
    /// .then("the transaction fails with insufficient funds") { result in
    ///     #expect(result.status == .rejected)
    ///     >>>result
    /// }
    /// .but("the account balance remains untouched on the server") { result in
    ///     let currentBalance = await ledger.fetchBalance(for: result.account.id)
    ///     #expect(currentBalance == 50)
    /// }
    /// ```
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

    /// Chains the primary action step that triggers the asynchronous behavior under test.
    ///
    /// Use `when` to execute the core asynchronous operation, network request, or concurrent interaction that
    ///   transitions the scenario from its initial preconditions to its observable outcome.
    ///
    /// ```swift
    /// await given("an authenticated payment client and an active invoice") {
    ///     let client = PaymentClient.mock()
    ///     let invoice = Invoice(id: "inv-001", amount: 42.0)
    ///     >>>client
    ///     >>>invoice
    /// }
    /// .when("the client submits the payment transaction over the network") { client, invoice in
    ///     try await client.charge(invoice: invoice)
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
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func when<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains the outcome verification step that asserts expected state changes asynchronously.
    ///
    /// Use `then` to observe and validate the results produced by the preceding `when` action, ensuring all
    ///   post-conditions, asynchronous responses, or database mutations meet expectations.
    ///
    /// ```swift
    /// await given("a user registration form") {
    ///     RegistrationForm(email: "blob@vinapp.id", password: "validPassword123")
    /// }
    /// .when("the form is submitted to the backend") { form in
    ///     try await form.submit()
    /// }
    /// .then("a new user profile is created with the given email") { profile in
    ///     #expect(profile.email == "blob@vinapp.id")
    ///     let remoteRecord = try await database.fetchUser(id: profile.id)
    ///     #expect(remoteRecord != nil)
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func then<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }
}

// MARK: - Asynchronous Extended Keywords

/// Extended asynchronous step keywords for temporal observation and contract validation.
extension GherkinStep {

    /// Chains a temporal step that inspects state or asynchronous side effects after the primary action completes.
    ///
    /// Use `after` to perform delayed validations, await asynchronous background tasks,
    ///   or inspect telemetry emitted following the execution of `when`.
    ///
    /// ```swift
    /// await given("an analytics service tracking screen visits") {
    ///     AnalyticsClient.mock()
    /// }
    /// .when("the user opens the settings screen") { client in
    ///     await client.trackScreen("settings")
    ///     return client
    /// }
    /// .after("the event is batched and flushed to remote storage") { client in
    ///     let flushed = try await client.fetchFlushedEvents()
    ///     #expect(flushed.contains("settings"))
    /// }
    /// ```
    ///
    /// If an earlier step in the pipeline threw an error, this step is skipped and the error is forwarded.
    ///
    /// - Parameters:
    ///   - _: An optional human-readable description of the step used for test clarity and reporting.
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func after<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }

    /// Chains a conditional assertion step that asynchronously verifies invariants and requirements.
    ///
    /// Use `should` to explicitly assert prerequisites or invariant contracts that must hold true before proceeding
    ///   further down the scenario chain.
    ///
    /// ```swift
    /// await given("a server configuration request") {
    ///     try await fetchRemoteConfig()
    /// }
    /// .should("contain a valid feature flags dictionary") { config in
    ///     let isValid = await configValidator.validate(config)
    ///     guard isValid else {
    ///         throw ConfigurationError.invalidSchema
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
    ///   - work: An asynchronous closure receiving the output of the previous step. Marked with ``PassthroughBuilder``
    ///     to support passing multiple values using the ``>>>(_:)`` operator or a standard return value.
    /// - Returns: A new ``GherkinStep`` containing the value produced by `work`, or carrying forward an upstream error.
    @discardableResult
    public func should<U>(_: String? = nil, @PassthroughBuilder work: (T) async throws -> U) async -> GherkinStep<U> {
        await asynchronousFlatMap(work)
    }
}

// MARK: - Private Helpers

extension GherkinStep {

    /// Evaluates the asynchronous transformation closure if the current step succeeded,
    ///   or propagates an existing failure.
    ///
    /// - Parameter transform: The throwing asynchronous transformation closure to execute on the payload `T`.
    /// - Returns: A new `GherkinStep` holding either the transformed value of type `U` or the caught error.
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
