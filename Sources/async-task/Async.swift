//
//  Async.swift
//  async-task
//
//  Created by Igor Shelopaev on 28.11.24.
//

import Foundation

/// A namespace for organizing type aliases and types related to asynchronous operations.
///
/// The `Async` namespace provides reusable abstractions for closures, state management,
/// and other tools designed for working with asynchronous programming patterns in Swift.
/// It simplifies common tasks like transformation, result generation, and task state tracking.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum Async {}

public extension Async {
    /// A closure that asynchronously transforms an input of type `Input` into an output of type `Output`.
    ///
    /// Use this type alias to represent an asynchronous operation that processes an input
    /// value and produces a transformed output. The operation may fail by throwing an error.
    ///
    /// - Parameters:
    ///   - Input: The type of the input value to be processed.
    ///   - Output: The type of the result produced after processing the input asynchronously.
    /// - Note: The `Input` and `Output` types must conform to `Sendable` to ensure thread safety
    ///         when used in Swift's structured concurrency model.
    /// - Throws: An error if the asynchronous operation cannot complete successfully.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    typealias Mapper<Input: Sendable, Output: Sendable> = @Sendable (Input) async throws -> Output

    /// A closure that asynchronously produces an output of type `Output` without requiring any input.
    ///
    /// Use this type alias to represent an asynchronous operation that generates a result
    /// without needing an input value. The operation may fail by throwing an error.
    ///
    /// - Parameters:
    ///   - Output: The type of the result produced by the asynchronous operation.
    /// - Note: The `Output` type must conform to `Sendable` to ensure thread safety
    ///         when used in Swift's structured concurrency model.
    /// - Throws: An error if the asynchronous operation cannot complete successfully.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    typealias Producer<Output: Sendable> = @Sendable () async throws -> Output
}

public extension Async {
    /// Represents the current state of an asynchronous operation.
    ///
    /// Use the `State` enum to track whether an asynchronous task is idle or actively running.
    /// This abstraction is useful for managing the lifecycle of tasks in a concise and reactive way.
    ///
    /// - Cases:
    ///   - `idle`: Indicates that no task is currently running.
    ///   - `active`: Indicates that a task is currently in progress.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    enum State {
        /// No task is currently running.
        case idle
        
        /// A task is currently in progress.
        case active
        
        /// A computed property to check if the state is active.
        ///
        /// - Returns: `true` if the state is `.active`, otherwise `false`.
        var isActive: Bool {
            self == .active
        }
    }
}
