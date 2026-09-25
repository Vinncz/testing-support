# ``TestingSupport``

A lightweight, fluent Behavior-Driven Development (BDD) testing library for Swift.

## Overview

**TestingSupport** brings structured, human-readable Gherkin syntax to Swift testing. It integrates cleanly with Swift Testing and XCTest, providing declarative state pipelines that pass data between steps without mutable external variables.

```swift
import Testing
import TestingSupport

@Test("User authentication scenario")
func testUserAuthentication() async throws {
    try await given("an unauthenticated user") {
        >>>User(name: "Alice", role: .guest)
    }
    .when("logging in with valid credentials") { user in
        let session = try await authService.login(user)
        >>>(user, session)
    }
    .then("session token is active") { user, session in
        #expect(session.isValid)
    }
    .finally {
        await authService.logout()
    }
}
```

### Key Capabilities

- **Familiar Gherkin Syntax**: Use `given`, `when`, `then`, `and`, `but`, `should`, `with`, `after`, and `finally` to articulate scenarios clearly.
- **Declarative Data Pipelining**: Stream data downstream effortlessly with ``PassthroughBuilder`` and the prefix ``>>>(_:)`` operator, avoiding leaky test state.
- **Seamless Swift Concurrency**: Full first-class support for `async`/`await` across all steps in the pipeline.
- **Resilient Teardown**: Guaranteed execution of ``GherkinStep/finally(_:work:)-i990`` and ``GherkinStep/finally(_:work:)-4nczx`` blocks regardless of whether earlier steps succeeded or threw errors.
- **Automatic Short-Circuiting**: Any thrown error immediately short-circuits subsequent action steps, forwarding the failure directly to the test runner or cleanup handler.

## Topics

### Getting Started

- <doc:GettingStarted>

### Scenario Initialization (Synchronous)

- ``given(_:work:)-3cupj``
- ``given(_:of:work:)-5ocj9``
- ``given(of:work:)-5gmlt``
- ``given(_:value:)-8zlml``
- ``given(value:)-k97b``

### Scenario Initialization (Asynchronous)

- ``given(_:work:)-73hhv``
- ``given(_:of:work:)-32ocs``
- ``given(of:work:)-3jynr``
- ``given(_:value:)-1tmae``
- ``given(value:)-54csi``

### Pipeline Execution

- ``GherkinStep``
- ``PassthroughValue``
- ``PassthroughBuilder``
- ``>>>(_:)``
