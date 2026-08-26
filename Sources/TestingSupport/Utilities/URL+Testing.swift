import Backport
import Foundation

/// Testing directory support extension.
extension URL {

    /// The directory that you could use for testing.
    ///
    /// By further scoping the directory off of this attribute, you could achieve the following directory structure,
    /// making inspection that much easier.
    ///
    /// ```
    /// ~/Library/Caches/BaseTestDirectory
    /// ~/Library/Caches/BaseTestDirectory/FilesystemPruner
    /// ~/Library/Caches/BaseTestDirectory/GherkinStep
    /// ```
    private static let baseTestingDirectory: URL = {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            preconditionFailure("Did fail to locate the caches directory in UserDomainMask.")
        }

        return cachesDirectory.appendingPathComponent("BaseTestDirectory", isDirectory: true)
    }()

    /// Creates a dedicated subdirectory for the provided scope,
    /// keeping tests isolated from one another.
    public static func testingDirectory(scopedTo scope: Any.Type) -> URL {
        do {
            return try URL.baseTestingDirectory.materialized
                .appendingPathComponent(String(describing: scope), isDirectory: true)
                .materialized
        } catch {
            preconditionFailure(
                """
                Did fail to scope a testing directory.
                
                Attempted Path: \(URL.baseTestingDirectory.path)
                Underlying Error: \(error.localizedDescription)
                """
            )
        }
    }
}
