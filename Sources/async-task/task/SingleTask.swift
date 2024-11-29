//
//  SingleTask.swift
//
//
//  Created by Igor Shelopaev on 27.11.24.
//

import SwiftUI


extension Async {
    /// A view model that manages a cancellable asynchronous task.
    ///
    /// This view model handles the lifecycle of a single asynchronous task in a SwiftUI environment.
    /// It provides features such as task cancellation, error handling, and state management, making
    /// it easier to integrate asynchronous operations into declarative UI workflows.
    ///
    /// - Note: The `@MainActor` attribute ensures all updates to properties and method calls occur on
    ///         the main thread, making it safe for use with SwiftUI.
    @MainActor
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public final class SingleTask<V: Sendable, E: Error>: ObservableObject, IAsyncTask {
        
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
        
        /// The custom error handler used to process errors during task execution.
        public let errorMapper: ErrorMapper<E>?
        
        // MARK: - Private Properties
        
        /// The currently running task, if any.
        ///
        /// This property holds a reference to the task to enable cancellation and lifecycle management.
        private var task: Task<Void, Never>?
        
        // MARK: - Initialization
        
        /// Creates a new instance of `SingleTask`.
        ///
        /// - Parameter errorMapper: A closure for custom error handling. Defaults to `nil`.
        public init(errorMapper: ErrorMapper<E>? = nil) {
            self.errorMapper = errorMapper
        }
        
        // MARK: - Public Methods
               
        /// Cancels the currently running task, if any.
        ///
        /// This method stops the task, resets its reference, and updates the state to `.idle`.
        public func cancel() {
            if let task {
                task.cancel()
                self.task = nil
            }
            setState(.idle)
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
        public func startTask(_ operation: @escaping Producer<V>) {
            
            cancel()
            clean()
            setState(.active)

            task = Task<Void, Never> { @MainActor [weak self] in
                
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
        
        /// Clears specified properties of the asynchronous task.
        ///
        /// This method allows selective clearing of task properties, such as `error` or `value`.
        /// By default, both `error` and `value` properties are cleared unless specific properties
        /// are specified in the `fields` parameter.
        ///
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
        
        @MainActor
        private func setState(_ value: State){
            state = value
        }
    }
}
