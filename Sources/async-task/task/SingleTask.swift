//
//  ViewModel.swift
//  async-location-swift-example
//
//  Created by Igor Shelopaev on 27.11.24.
//

import SwiftUI

extension Async {
    /// A view model that manages a cancellable asynchronous task.
    ///
    /// This view model handles the lifecycle of a single asynchronous task in a SwiftUI environment.
    /// It provides features such as task cancellation, error handling, and state management, making
    /// it easier to integrate asynchronous operations into reactive UI workflows.
    ///
    /// - Note: The `@MainActor` attribute ensures all updates to properties and method calls occur on
    ///         the main thread, making it safe for use with SwiftUI.
    @MainActor
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public final class SingleTask<V: Sendable, E: Error>: ObservableObject {
        
        // MARK: - Type Aliases
        
        /// A closure type for handling errors.
        ///
        /// This closure processes an optional `Error` and returns an optional custom error of type `E`.
        public typealias ErrorHandler = @Sendable (Error?) -> E?
        
        // MARK: - Public Properties
        
        /// The error encountered during the task, if any.
        ///
        /// This property is updated whenever an error occurs during task execution.
        @Published public private(set) var error: E?
        
        /// The result produced by the asynchronous task, if available.
        ///
        /// This property holds the value produced by a successfully completed task.
        @Published public private(set) var value: V?
        
        /// The current state of the task.
        ///
        /// Indicates whether the task is currently active or idle.
        @Published public private(set) var state: Async.State = .idle
        
        // MARK: - Private Properties
        
        /// The custom error handler used to process errors during task execution.
        private let errorHandler: ErrorHandler?
        
        /// The currently running task, if any.
        ///
        /// This property holds a reference to the task to enable cancellation and lifecycle management.
        private var task: Task<V?, Never>?
        
        // MARK: - Initialization
        
        /// Creates a new instance of `SingleTask`.
        ///
        /// - Parameter errorHandler: A closure for custom error handling. Defaults to `nil`.
        public init(errorHandler: ErrorHandler? = nil) {
            self.errorHandler = errorHandler
        }
        
        // MARK: - Public Methods
        
        /// Clears the current value and error state.
        ///
        /// Use this method to reset the view model before starting a new task.
        public func clean() {
            error = nil
            value = nil
        }
        
        /// Cancels the currently running task, if any.
        ///
        /// This method stops the task, resets its reference, and updates the state to `.idle`.
        public func cancel() {
            state = .idle
            
            if let task {
                task.cancel()
            }
            
            task = nil
        }
        
        /// Starts an asynchronous operation without requiring input.
        ///
        /// This method initializes an asynchronous task using the provided `Producer` closure.
        /// It resets the current state, starts the task, and handles its lifecycle, including
        /// error management and state updates.
        ///
        /// - Parameter operation: A closure that performs an asynchronous task and returns
        ///   a value of type `V` upon completion. The closure can throw an error if the task fails.
        ///
        /// - Note: Ensures all updates occur on the main actor, making it safe for use in UI-related contexts.
        @MainActor
        public func start(operation: @escaping Producer<V>) {
            startTask {
                try await operation()
            }
        }

        /// Starts an asynchronous operation with a specified input.
        ///
        /// This method initializes an asynchronous task using the provided `Mapper` closure and input value.
        /// It resets the current state, starts the task, and handles its lifecycle, including error management
        /// and state updates.
        ///
        /// - Parameters:
        ///   - operation: A closure that takes an input of type `I`, performs an asynchronous task, and
        ///     returns a value of type `V` upon completion. The closure can throw an error if the task fails.
        ///   - input: The input value of type `I` to be passed to the `operation` closure.
        ///
        /// - Note: Both `I` and `V` must conform to `Sendable` to ensure thread safety in Swift's concurrency model.
        @MainActor
        public func start<I: Sendable>(with input: I, operation: @escaping Mapper<I, V>) {
            startTask {
                try await operation(input)
            }
        }
       
        // MARK: - Private Methods
        
        /// Executes an asynchronous operation and manages its lifecycle.
        ///
        /// This private method centralizes the common functionality for running an asynchronous task.
        /// It resets the current state, starts the task, manages errors, and updates the task's state.
        ///
        /// - Parameter operation: A closure that performs an asynchronous task and returns a value
        ///   of type `V` upon completion. The closure can throw an error if the task fails.
        ///
        /// - Note: Ensures thread safety by running on the main actor, making it suitable for managing
        ///         UI-related tasks or state changes.
        @MainActor
        private func startTask(_ operation: @escaping () async throws -> V) {
            clean() // Reset the current state before starting the task.
            state = .active // Mark the task as active.

            task = Task {
                do {
                    value = try await operation() // Execute the asynchronous operation and store the result.
                } catch {
                    handle(error) // Process any errors encountered during execution.
                    cancel() // Reset the state by cancelling the task.
                }

                state = .idle // Mark the task as idle once it completes.
                return value
            }
        }
        
        /// Handles errors encountered during task execution.
        ///
        /// This method processes the error using the custom error handler, if provided. If no handler is available,
        /// it attempts to cast the error to the expected type `E`. If the error cannot be cast, the error state is cleared.
        ///
        /// - Parameter error: The error encountered during task execution.
        @MainActor
        private func handle(_ error: Error) {
            if let error = errorHandler?(error) {
                self.error = error
            } else if let error = error as? E {
                self.error = error
            } else {
                self.error = nil
            }
        }
    }
}
