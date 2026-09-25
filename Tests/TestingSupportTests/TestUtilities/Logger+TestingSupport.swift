import Foundation
import OSLog

/// Instance extension.
extension Logger {

    /// Logger that is used in test cases.
    static let testing = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "TestingSupport",
        category: "Testing"
    )
}
