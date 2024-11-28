//
//  File.swift
//  async-task
//
//  Created by Igor  on 28.11.24.
//

import Foundation

/// A protocol defining the behavior of a cancellable asynchronous task manager.
@MainActor
public protocol IAsyncTask: AnyObject {

        associatedtype Value: Sendable
        associatedtype ErrorType: Error, Sendable

        // MARK: - Properties

        /// The error encountered during the task, if any.
        var error: ErrorType? { get }

        /// The result produced by the asynchronous task, if available.
        var value: Value? { get }

        /// The current state of the task.
        var state: Async.State { get }
    
        var errorMapper: Async.ErrorMapper<ErrorType>? { get }

        // MARK: - Methods

        /// Clears the current value and error state.
        func clean()

        /// Cancels the currently running task, if any.
        func cancel()

        /// Starts an asynchronous operation without requiring input.
        ///
        /// - Parameter operation: A closure that performs an asynchronous task and returns
        ///   a value of type `Value` upon completion. The closure can throw an error if the task fails.
        func start(operation: @escaping Async.Producer<Value>)

        /// Starts an asynchronous operation with a specified input.
        ///
        /// - Parameters:
        ///   - input: A value of type `I` to be passed to the `operation` closure.
        ///   - operation: A closure that takes an input of type `I`, performs an asynchronous task, and
        ///     returns a value of type `Value` upon completion. The closure can throw an error if the task fails.
        func start<I: Sendable>(with input: I, operation: @escaping Async.Mapper<I, Value>)
    }

extension IAsyncTask{
    /// Handles errors encountered during task execution.
    ///
    /// This method processes the error using the custom error handler, if provided. If no handler is available,
    /// it attempts to cast the error to the expected type `E`. If the error cannot be cast, the error state is cleared.
    ///
    /// - Parameter error: The error encountered during task execution.
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
