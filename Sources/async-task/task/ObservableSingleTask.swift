//
//  ObservableSingleTask.swift
//  async-task
//
//  Created by Igor Shelopaev on 28.11.24.
//

import SwiftUI

extension Async {
    /// A view model for managing a cancellable asynchronous task in a SwiftUI environment.
    ///
    /// This class provides lifecycle management for a single asynchronous task, including cancellation,
    /// error handling, and state management. It ensures compatibility with SwiftUI’s declarative UI workflows
    /// and guarantees thread safety by operating exclusively on the main actor.
    ///
    /// - Note: Uses `@Observable` to automatically notify SwiftUI views of state changes.
    @MainActor
    @Observable
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public final class ObservableSingleTask<V: Sendable, E: Error>: IAsyncTask {
        
        // MARK: - Public Properties
        
        /// The error encountered during the task, if any.
        ///
        /// This property is set when the task encounters an error, either through the custom `errorMapper`
        /// or directly from the task itself.
        public private(set) var error: E?
        
        /// The result produced by the asynchronous task, if available.
        ///
        /// This property holds the task's output upon successful completion.
        public private(set) var value: V?
        
        /// The current state of the task.
        ///
        /// Indicates whether the task is idle, active, or completed. This property can be used to track
        /// the task’s progress and update the UI accordingly.
        public private(set) var state: Async.State = .idle
        
        /// A custom error handler for mapping generic errors to the specified error type `E`.
        ///
        /// This optional closure allows customization of error handling logic, enabling context-specific transformations.
        public let errorMapper: ErrorMapper<E>?
        
        // MARK: - Private Properties
        
        /// A reference to the currently running task.
        ///
        /// This property enables cancellation and lifecycle management of the asynchronous task.
        private var task: Task<Void, Never>?
        
        // MARK: - Initialization
        
        /// Initializes a new instance of `ObservableSingleTask`.
        ///
        /// - Parameter errorMapper: A closure for custom error handling. Defaults to `nil`.
        public init(errorMapper: ErrorMapper<E>? = nil) {
            self.errorMapper = errorMapper
        }
        
        // MARK: - Public Methods
        
        /// Resets the current value and error state.
        ///
        /// Call this method to clear the task’s result and error before starting a new task
        /// or after processing the current state.
        public func clean() {
            error = nil
            value = nil
        }
        
        /// Cancels the currently running task, if any.
        ///
        /// Stops the task immediately, clears its reference, and updates the state to `.idle`.
        /// Safe to call even if no task is currently running.
        public func cancel() {
            if let task {
                task.cancel()
                self.task = nil
            }
            setState(.idle)
        }
        
        /// Starts an asynchronous operation without input.
        ///
        /// Initializes and manages the lifecycle of an asynchronous task. Resets the state,
        /// starts the task, and handles errors or results automatically.
        ///
        /// - Parameter operation: A closure that performs an asynchronous task and returns
        ///   a value of type `V`. The closure can throw an error if the task fails.
        public func start(operation: @escaping Producer<V>) {
            startTask {
                try await operation()
            }
        }

        /// Starts an asynchronous operation with an input value.
        ///
        /// Initializes and manages the lifecycle of an asynchronous task with a provided input.
        /// Ensures proper error and state handling during execution.
        ///
        /// - Parameters:
        ///   - input: A value of type `I` passed to the `operation` closure.
        ///     If `input` is a reference type, ensure its internal properties are immutable or concurrency-safe.
        ///   - operation: A closure that takes an input of type `I`, performs an asynchronous task, and
        ///     returns a value of type `V`. The closure can throw an error if the task fails.
        public func start<I: Sendable>(with input: I, operation: @escaping Mapper<I, V>) {
            startTask {
                try await operation(input)
            }
        }
       
        // MARK: - Private Methods
        
        /// Manages the lifecycle of an asynchronous task.
        ///
        /// Centralizes task execution, state updates, and error handling. Automatically
        /// cleans up and transitions the task's state after completion or failure.
        ///
        /// - Parameter operation: A closure that performs an asynchronous task and returns
        ///   a value of type `V`. The closure can throw an error if the task fails.
        private func startTask(_ operation: @escaping Producer<V>) {
            cancel()
            clean()
            setState(.active)

            task = Task<Void, Never> { [weak self] in
                defer {
                    self?.setState(.idle)
                    self?.task = nil
                }
                do {
                    self?.value = try await operation()
                } catch {
                    self?.error = self?.handle(error)
                }
            }
        }
        
        /// Updates the task state.
        ///
        /// - Parameter value: The new state to assign.
        private func setState(_ value: State) {
            state = value
        }
    }
}
