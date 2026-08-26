import Foundation

/// A generic error to be thrown to simulate throwing in a function.
public enum FakeError: Error {

    case deserializeFailure

    case diskFull

    case diskPermissionDenied

    case networkForbidden

    case networkTimeout

    case networkUnauthenticated
}
