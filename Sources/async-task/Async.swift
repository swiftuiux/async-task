//
//  Async.swift
//  async-task
//
//  Created by Igor Shelopaev  on 28.11.24.
//

import Foundation

/// A namespace for organizing type aliases related to asynchronous operations.
///
/// The `Async` enum provides type-safe and reusable aliases for closures used in
/// asynchronous programming, making it easier to work with common patterns like
/// transformation and result generation in a concurrent environment.
enum Async {}

extension Async {
    /// A closure that asynchronously transforms an input of type `Input` into an output of type `Output`.
    ///
    /// This type alias represents an asynchronous operation that takes an input value, processes it,
    /// and produces a transformed output. The operation may throw an error if it fails.
    ///
    /// - Parameters:
    ///   - Input: The type of the input value to be processed.
    ///   - Output: The type of the result produced after the asynchronous operation.
    /// - Note: The `Input` and `Output` types must conform to `Sendable` to ensure thread safety
    ///         in concurrent contexts.
    /// - Throws: An error if the asynchronous operation cannot complete successfully.
    typealias Mapper<Input: Sendable, Output: Sendable> = @Sendable (Input) async throws -> Output

    /// A closure that asynchronously produces an output of type `Output` without requiring any input.
    ///
    /// This type alias represents an asynchronous operation that performs some work and returns
    /// a result. The operation may throw an error if it fails.
    ///
    /// - Parameters:
    ///   - Output: The type of the result produced by the asynchronous operation.
    /// - Note: The `Output` type must conform to `Sendable` to ensure thread safety
    ///         in concurrent contexts.
    /// - Throws: An error if the asynchronous operation cannot complete successfully.
    typealias Producer<Output: Sendable> = @Sendable () async throws -> Output
}
