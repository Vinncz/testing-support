import Foundation

extension GherkinStep {

    /// Evaluates the asynchronous transformation closure if the current step succeeded,
    ///   or propagates an existing failure.
    ///
    /// - Parameter transform: The throwing asynchronous transformation closure to execute on the payload `T`.
    /// - Returns: A new `GherkinStep` holding either the transformed value of type `U` or the caught error.
    func asynchronousFlatMap<U>(_ transform: (T) async throws -> U) async -> GherkinStep<U> {
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
