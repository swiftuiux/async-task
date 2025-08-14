//
//  IAsyncTask.swift
//  async-task
//
//  Created by Igor Shelopaev on 28.11.24.
//

import Foundation

/// A protocol defining the behavior of an asynchronous task manager with cancellation and error handling capabilities.
///
/// This protocol abstracts the lifecycle management of a cancellable asynchronous task. It provides functionalities
/// such as state management, error handling, and task cancellation, making it easier to integrate asynchronous
/// operations into applications with a consistent and reusable interface.
///
/// - Note: This protocol is designed to work in environments where updates must occur on the main actor,
///         ensuring thread safety for UI-related operations.
@MainActor
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol IAsyncTask: AnyObject{
    
    /// The type of the value produced by the asynchronous task.
    associatedtype Value: Sendable
    
    /// The type of the error that may occur during the asynchronous task's execution.
    associatedtype ErrorType: Error, Sendable

    // MARK: - Properties

    /// The error encountered during the task, if any.
    ///
    /// This property is updated whenever an error occurs during task execution. The error can be
    /// mapped into a custom error type using the `errorMapper` if provided.
    var error: ErrorType? { get }

    /// The result produced by the asynchronous task, if available.
    ///
    /// This property holds the value produced by a successfully completed task. If the task fails
    /// or has not yet completed, this property will be `nil`.
    var value: Value? { get }

    /// The current state of the task.
    ///
    /// Indicates whether the task is idle, active, or completed. This property helps in tracking the
    /// task's lifecycle and can be used to trigger UI updates or other logic based on task status.
    var state: Async.State { get }
    
    /// A custom error mapper used to process and transform errors encountered during task execution.
    ///
    /// This closure allows custom error handling and mapping of generic errors into the specified `ErrorType`.
    /// If not provided, errors will not be automatically transformed.
    var errorMapper: Async.ErrorMapper<ErrorType>? { get }

    /// Initializer
    ///
    /// - Parameter errorMapper: A closure for custom error handling, allowing transformation of
    ///   errors into the specified error type `E`. Defaults to `nil`.
    init(errorMapper: Async.ErrorMapper<ErrorType>?)
    
    // MARK: - Methods

    /// Cancels the currently running task, if any.
    ///
    /// This method stops the task immediately, resets the task reference, and updates the state to `.idle`.
    /// If no task is running, calling this method has no effect.
    func cancel()

    /// Starts an asynchronous operation without requiring input.
    ///
    /// This method initializes an asynchronous task using the provided closure. It resets the current state,
    /// starts the task, and handles its lifecycle, including error management and state updates.
    ///
    /// - Parameters:
    ///   - priority: The priority of the task, which determines its scheduling priority in the system.
    ///   - operation: A closure that performs an asynchronous task and returns
    ///     a value of type `Value` upon completion. The closure can throw an error if the task fails.
    func start(priority: TaskPriority?, operation: @escaping Async.Producer<Value?>)

    /// Starts an asynchronous operation with a specified input.
    ///
    /// This method initializes an asynchronous task using the provided closure and input value.
    /// The input can be of any type conforming to `Sendable`, ensuring thread safety for concurrent operations.
    ///
    /// - Parameters:
    ///   - input: A value of type `I` to be passed to the `operation` closure.
    ///   - priority: The priority of the task, which determines its scheduling priority in the system.
    ///   - operation: A closure that takes an input of type `I`, performs an asynchronous task, and
    ///     returns a value of type `Value` upon completion. The closure can throw an error if the task fails.
    func start<I: Sendable>(with input: I, priority: TaskPriority?, operation: @escaping Async.Mapper<I, Value?>)
    
    /// Executes an asynchronous operation and manages its lifecycle.
    ///
    /// This requirement centralizes the common functionality for running an asynchronous task.
    ///
    /// - Parameters:
    ///   - priority: The priority of the task, which determines its scheduling priority in the system.
    ///   - operation: A closure that performs an asynchronous task and returns a value
    ///     of type `Value` upon completion. The closure can throw an error if the task fails.
    ///
    /// - Note: Ensures thread safety by running on the main actor, making it suitable for managing
    ///         UI-related tasks or state changes.
    func startTask(priority: TaskPriority?, _ operation: @escaping Async.Producer<Value?>)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension IAsyncTask {
    
    /// Starts an asynchronous operation without requiring input.
    ///
    /// This method initializes an asynchronous task using the provided `Producer` closure.
    /// It resets the current state, starts the task, and handles its lifecycle, including
    /// error management and state updates.
    ///
    /// - Parameters:
    ///   - priority: The priority of the task, which determines its scheduling priority in the system.
    ///   - operation: A closure that performs an asynchronous task and returns
    ///     a value of type `Value` upon completion. The closure can throw an error if the task fails.
    ///
    /// - Note: Ensures all updates occur on the main actor, making it safe for use in UI-related contexts.
    @MainActor
    public func start(priority: TaskPriority? = nil, operation: @escaping Async.Producer<Value?>) {
        startTask(priority: priority) {
            try await operation()
        }
    }
    
    /// Starts an asynchronous operation with a specified input.
    ///
    /// This method initializes an asynchronous task using the provided `Mapper` closure and input value.
    /// While the `input` is treated as immutable within the operation, this immutability applies only
    /// to the reference if `input` is a class. For complete immutability, the inner properties or nested
    /// objects within the `input` must also be designed to prevent mutation (e.g., using `final`, `let`, or `Sendable`-conformant types).
    ///
    /// - Parameters:
    ///   - input: A value of type `I` to be passed to the `operation` closure. If `input` is a reference type,
    ///     its immutability is limited to the reference itself, and its internal state may still be mutable.
    ///   - priority: The priority of the task, which determines its scheduling priority in the system.
    ///   - operation: A closure that takes an input of type `I`, performs an asynchronous task, and
    ///     returns a value of type `Value` upon completion. The closure can throw an error if the task fails.
    @MainActor
    public func start<I: Sendable>(with input: I, priority: TaskPriority? = nil, operation: @escaping Async.Mapper<I, Value?>) {
        startTask(priority: priority) {
            try await operation(input)
        }
    }
    
    /// Processes and maps errors encountered during task execution.
    ///
    /// This method uses the custom error mapper to transform errors into the expected type `ErrorType`.
    /// If no custom mapper is provided, it attempts to cast the error directly to `ErrorType`.
    /// If the error cannot be mapped or cast, the error state is cleared.
    ///
    /// - Parameter error: The error encountered during task execution.
    /// - Returns: A mapped or cast error of type `ErrorType`, or `nil` if the error could not be processed.
    @MainActor
    public func handle(_ error: Error) -> ErrorType? {
        if let error = errorMapper?(error) {
            return error
        } else if let error = error as? ErrorType {
            return error
        }
        
        return nil
    }
}
