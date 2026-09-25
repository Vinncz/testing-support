# Getting Started with TestingSupport

Learn how to write expressive, maintainable Behavior-Driven Development (BDD) tests using fluent Gherkin syntax and declarative data pipelines.

## Overview

Traditional unit tests often intermingle setup, execution, assertion, and state management within a single procedural function. As tests grow, it becomes difficult to understand the intent of each step or pinpoint where a failure occurred.

**TestingSupport** separates concerns by organizing tests into distinct, sequential steps that mirror human language:
- **Given**: Initial context or system state
- **When**: Action or trigger being exercised
- **Then**: Observed behavior or primary assertion
- **And / But**: Additional sequential actions or contrasting context
- **Should / With / After**: Invariant checks, auxiliary configurations, and post-action hooks
- **Finally**: Guaranteed cleanup and error propagation

---

## Writing Your First Scenario

Here is a basic synchronous test written with Swift Testing:

```swift
import Testing
import TestingSupport

@Suite("Shopping Cart Tests")
struct ShoppingCartTests {

    @Test("Adding an item increases cart total")
    func testAddItem() throws {
        try given("an empty cart and an item costing $20") {
            let cart = ShoppingCart()
            let item = Item(name: "Book", price: 20)
            >>>(cart, item)
        }
        .when("the item is added to the cart") { cart, item in
            cart.add(item)
            >>>cart
        }
        .then("the total should equal $20") { cart in
            #expect(cart.total == 20)
            #expect(cart.items.count == 1)
        }
        .finally {
            // Teardown / cleanup if needed
        }
    }
}
```

---

## Passing Data with the `>>>` Operator

`TestingSupport` avoids mutable variables scoped outside your test steps. Instead, data flows down the pipeline via ``PassthroughBuilder`` and the prefix ``>>>(_:)`` operator:

1. **Mark values with `>>>`**: Prepend `>>>` to any expression you want to forward to the next step.
2. **Tuple auto-packing**: If you mark a tuple `>>>(user, token)`, the next step receives `(user, token)` as closure arguments.
3. **Ignore side effects**: Unmarked expressions (such as logging or helper calls) execute normally but are excluded from the forwarded payload.

```swift
given("configuration data") {
    let host = "https://api.example.com"
    let timeout: TimeInterval = 30
    
    // Only host and timeout are passed down
    >>>(host, timeout)
}
.when("client connects") { host, timeout in
    let client = NetworkClient(host: host, timeout: timeout)
    >>>client
}
.then("client is connected") { client in
    #expect(client.isConnected)
}
```

---

## Asynchronous Pipelines (`async`/`await`)

TestingSupport provides seamless integration with Swift Concurrency. If any step is asynchronous, use `await` when starting the scenario with `given`:

```swift
@Test("Fetching remote profile")
func testFetchProfile() async throws {
    try await given("an authenticated user id") {
        >>>"usr_98765"
    }
    .when("fetching profile from API") { userId in
        let profile = try await apiService.fetchProfile(id: userId)
        >>>profile
    }
    .then("display name matches") { profile in
        #expect(profile.displayName == "Taylor")
    }
    .finally {
        await apiService.invalidateCache()
    }
}
```

---

## Error Handling & Guaranteed Cleanup

- **Short-Circuiting**: If any step in the pipeline throws an error, all subsequent action steps (`when`, `then`, `and`, `should`, etc.) are skipped immediately.
- **Guaranteed Cleanup**: The `finally` block is guaranteed to execute regardless of whether the pipeline succeeded or failed. Once cleanup finishes, `finally` rethrows the upstream error to fail the enclosing test case.

```swift
@Test("File processing with guaranteed teardown")
func testFileProcessing() throws {
    try given("a temporary file on disk") {
        let file = try TemporaryFile(name: "test.dat")
        >>>file
    }
    .when("corrupt data is written") { file in
        try file.write(corruptedBytes)
        >>>file
    }
    .then("processing fails with parsing error") { file in
        // If an error was thrown in `when`, this step is bypassed
        try file.process()
    }
    .finally {
        // This block runs unconditionally, cleaning up resources
        TemporaryFile.cleanAll()
    }
}
```

---

## Syntactic Sugar & Extended Keywords

Beyond `given`, `when`, and `then`, you can enhance readability with:

- **`and`**: Continues the preceding action or assertion sequentially.
- **`but`**: Expresses a contrasting condition or caveat.
- **`should`**: Asserts preconditions or postconditions inline.
- **`with`**: Applies auxiliary configuration to incoming values.
- **`after`**: Executes post-condition logic following an action.
