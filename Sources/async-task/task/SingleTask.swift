//
//  SingleTask.swift
//  async-task
//
//  Created by Igor Shelopaev on 27.11.24.
//

import SwiftUI

extension Async {
    /// A view model that manages a cancellable asynchronous task.
    ///
    /// This view model simplifies the lifecycle management of a single asynchronous task in a SwiftUI environment.
    /// It includes functionality for task cancellation, error handling, and state management, making it easier
    /// to integrate declarative workflows into asynchronous operations.
    ///
    /// - Note: The `@MainActor` attribute ensures thread safety, as all updates to properties and method calls
    ///         occur on the main thread, making it safe for use in UI-related contexts.
    @MainActor
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public final class SingleTask<V: Sendable, E: Error>: ObservableObject, IAsyncTask {
        
        // MARK: - Public Properties
        
        /// The error encountered during the task, if any.
        @Published public private(set) var error: E?
        
        /// The result produced by the asynchronous task, if available.
        @Published public private(set) var value: V?
        
        /// The current state of the task.
        ///
        /// Indicates whether the task is idle, active, or completed. This property helps track the
        /// task's lifecycle and can be used to trigger UI updates or other logic based on task status.
        @Published public private(set) var state: Async.State = .idle
        
        /// A custom error mapper used to process and transform errors encountered during task execution.
        ///
        /// Allows for the customization of error handling logic, mapping generic errors into a
        /// specified type of `E`. Defaults to `nil` if not provided.
        public let errorMapper: ErrorMapper<E>?
        
        // MARK: - Private Properties
        
        /// The currently running task, if any.
        ///
        /// Holds a reference to the running task, enabling cancellation and lifecycle management.
        private var task: Task<Void, Never>?
        
        // MARK: - Initialization
        
        /// Creates a new instance of `SingleTask`.
        ///
        /// - Parameter errorMapper: A closure for custom error handling, allowing for the transformation of
        ///   errors encountered during task execution. Defaults to `nil`.
        public init(errorMapper: ErrorMapper<E>? = nil) {
            self.errorMapper = errorMapper
        }
        
        // MARK: - Public Methods
               
        /// Cancels the currently running task, if any.
        public func cancel() {
            if let task {
                task.cancel()
                self.task = nil
            }
            setState(.idle)
        }
       
        /// Starts an asynchronous task with the specified operation.
        /// - Parameters:
        ///   - priority: The priority of the task, influencing its scheduling. Defaults to `nil`.
        ///   - operation: A closure that performs an asynchronous task and returns a value of type `V`.
        ///     The closure can throw an error if the task fails.
        ///
        /// - Note: Ensures thread safety by running on the main actor, making it suitable for managing
        ///         UI-related tasks or state changes.
        public func startTask(
            priority: TaskPriority? = nil,
            _ operation: @escaping Producer<V?>
        ) {
            cancel()
            clean()
            setState(.active)

            task = Task<Void, Never>(priority: priority) { @MainActor [weak self] in
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
        
        // MARK: - Private Methods
        
        /// Clears specified properties of the asynchronous task.
        /// - Parameter fields: An array of `TaskProperty` values specifying which properties
        ///   to clear. The default is `[.error, .value]`, which clears both the `error` and `value` properties.
        private func clean(fields: [Async.TaskProperty] = [.error, .value]) {
            for field in fields {
                switch field {
                    case .error: resetError()
                    case .value: resetValue()
                }
            }
        }
        
        /// Resets the `error` property of the asynchronous task.
        private func resetError() {
            self.error = nil
        }

        /// Resets the `value` property of the asynchronous task.
        private func resetValue() {
            self.value = nil
        }
        
        /// Updates the state of the asynchronous task.
        ///
        /// - Parameter value: The new state to set.
        @MainActor
        private func setState(_ value: State) {
            state = value
        }
    }
}
