import OSLog

/// Instance extension.
extension Logger {

    /// Logger that is used in test cases.
    public static let testing = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Testing")
}
