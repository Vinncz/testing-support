import Foundation

/// Testing directory support extension.
extension URL {

    /// The directory that you could use for testing.
    ///
    /// By further scoping the directory off of this attribute, you could achieve the following directory structure,
    ///   making inspection that much easier.
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
            return try baseTestingDirectory.materialized
                .appendingPathComponent(String(describing: scope), isDirectory: true)
                .materialized
        } catch {
            preconditionFailure(
                """
                Did fail to scope a testing directory.

                Attempted Path: \(baseTestingDirectory.path)
                Underlying Error: \(error.localizedDescription)
                """
            )
        }
    }

    /// Creates a directory or a file at the location this URL points to.
    ///
    /// This attribute bridges the concept of a location, and the reality of the file system.
    ///
    /// Accessing this property performs an IO creation implicitly:
    ///   1. Checks if the directory exists.
    ///   2. If not, creates it (including any missing parent directories).
    ///   3. Returns `self` that allows chaining.
    ///
    /// ## Usage
    /// ```swift
    /// let preferredReadLocation: URL = .testingDirectory(scopedTo: "BDD Test")
    /// let readLocation = try preferredReadLocation.materialized
    ///
    /// let repo = Repository(root: readLocation)
    /// ```
    ///
    /// - Throws: The error that `FileManager` throws, if the file system prevents creation (e.g., disk full).
    private var materialized: URL {
        get throws {
            try FileManager.default.createDirectory(
                at: self,
                withIntermediateDirectories: true
            )
            return self
        }
    }
}
