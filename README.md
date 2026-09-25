# TestingSupport

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange.svg?style=flat-square)](https://swift.org)
[![iOS 14.0+](https://img.shields.io/badge/iOS-14.0%2B-blue.svg?style=flat-square)](https://developer.apple.com/ios/)
[![SwiftPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat-square)](https://swift.org/package-manager/)
[![Documentation](https://img.shields.io/badge/DocC-Documentation-blueviolet.svg?style=flat-square)](https://vinncz.github.io/testing-support/documentation/testingsupport)

A lightweight, fluent Behavior-Driven Development (BDD) testing library for Swift. **TestingSupport** empowers developers to write clear, structured, and readable test scenarios using Gherkin keywords (`given`, `when`, `then`, `and`, `but`, `should`, `with`, `after`, `finally`) coupled with declarative data pipelining.

Works seamlessly with both **Swift Testing** (`@Suite`, `@Test`, `#expect`) and **XCTest**.

---

## Highlights

- **Fluent Gherkin Syntax**: Express intent naturally with `given`, `when`, `then`, `and`, `but`, `should`, `with`, `after`, and `finally`.
- **Declarative Data Pipelining**: Pass data and multi-element tuples downstream using `@PassthroughBuilder` and the prefix `>>>` operator without declaring mutable external variables.
- **First-Class Concurrency**: Native support for asynchronous setup, actions, and verification (`async`/`await`).
- **Guaranteed Cleanup**: The `finally` block runs unconditionally for reliable teardown even when prior steps throw errors.
- **Automatic Short-Circuiting**: Early errors halt downstream execution immediately, passing errors cleanly to the test runner or teardown handler.

---

## Quick Start

### Basic Scenario (Swift Testing)

```swift
import Testing
import TestingSupport

@Suite("Authentication Scenarios")
struct AuthenticationTests {

    @Test("Logging in with valid credentials yields an active session")
    func validLogin() throws {
        try given("an unauthenticated user with valid credentials") {
            let credentials = Credentials(username: "alice", password: "secretPassword")
            >>>credentials
        }
        .when("credentials are submitted to the auth service") { credentials in
            let session = AuthService.login(credentials: credentials)
            >>>session
        }
        .then("the resulting session is active and verified") { session in
            #expect(session.isActive)
            #expect(session.userId == "alice")
        }
        .finally {
            // Guaranteed cleanup runs regardless of success or failure
            AuthService.reset()
        }
    }
}
```

---

## Key Concepts

### 1. Pipelining Data with `>>>`

Avoid leaking mutable variables across your test body. Pass values forward to subsequent steps by marking expressions with the prefix `>>>` operator:

```swift
given("initial parameters") {
    let username = "johndoe"
    let retryLimit = 3
    >>>(username, retryLimit)
}
.when("initializing the client") { username, retryLimit in
    let client = APIClient(user: username, maxRetries: retryLimit)
    >>>client
}
.then("client configured properly") { client in
    #expect(client.user == "johndoe")
    #expect(client.maxRetries == 3)
}
```

Unmarked statements inside a block execute normally as side effects and are omitted from the forwarded payload.

### 2. Native Swift Concurrency (`async`/`await`)

Every Gherkin step has an asynchronous counterpart:

```swift
@Test("Async network fetch scenario")
func fetchRemoteUser() async throws {
    try await given("a registered user id") {
        >>>"usr_12345"
    }
    .when("querying the remote API") { id in
        let user = try await userService.fetchUser(id: id)
        >>>user
    }
    .then("user profile data matches expected attributes") { user in
        #expect(user.name == "John Doe")
    }
    .finally {
        await userService.clearSession()
    }
}
```

### 3. Extended Keywords for Expressive Scenarios

Use extended BDD keywords to articulate subtleties in your test logic:

- `and`: Continue action or verification steps sequentially.
- `but`: Introduce contrasting expectations or preconditions.
- `should`: Assert intermediate invariants inline.
- `with`: Supply parallel auxiliary context or configuration.
- `after`: Execute post-condition logic immediately following an action.

```swift
given("a shopping cart with items") {
    >>>Cart(items: ["Widget": 15.0])
}
.with("a 10% discount promo code") { cart in
    cart.applyDiscount(percent: 10)
    >>>cart
}
.when("checking out") { cart in
    let invoice = checkout(cart)
    >>>(cart, invoice)
}
.then("total reflects discount") { cart, invoice in
    #expect(invoice.total == 13.5)
}
.and("cart is cleared") { cart, _ in
    #expect(cart.isEmpty)
}
```

---

## Installation

Add **TestingSupport** as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Vinncz/testing-support.git", from: "1.0.0")
]
```

Then add it to your test target:

```swift
.testTarget(
    name: "MyProjectTests",
    dependencies: [
        .product(name: "TestingSupport", package: "testing-support")
    ]
)
```

---

## Documentation

Full API reference and articles are published on GitHub Pages:

**[Browse Full DocC Documentation](https://vinncz.github.io/testing-support/documentation/testingsupport)**

---

## License

This project is available under the MIT License.
