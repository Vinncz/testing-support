import Testing

extension Tag {

    /// Mark suites that verify the functionality of the foundational Gherkin keywords.
    @Tag static var standardKeywords: Self

    /// Mark suites that verify the functionality of data-passing between Gherkin blocks.
    @Tag static var dataFlow: Self

    /// Mark suites that verify the functionality of async operations during the execution of some Gherkin block.
    @Tag static var concurrency: Self

    /// Mark suites that verify that thrown errors are handled by the `finally` Gherkin block.
    @Tag static var errorHandling: Self

    /// Mark suites that verify the behavior of extra Gherkin blocks against the core ones.
    @Tag static var extendedSyntax: Self
}
