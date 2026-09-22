import Testing

// MARK: - Test Errors

enum ScenarioError: Error, Equatable, CustomTestStringConvertible {
    case deserializeFailure
    case diskFull
    case networkForbidden
    case networkTimeout
    case networkUnauthenticated

    var testDescription: String {
        switch self {
        case .deserializeFailure: "Deserialization failure"
        case .diskFull: "Disk full"
        case .networkForbidden: "Network forbidden (403)"
        case .networkTimeout: "Network request timed out"
        case .networkUnauthenticated: "Network unauthenticated (401)"
        }
    }
}
