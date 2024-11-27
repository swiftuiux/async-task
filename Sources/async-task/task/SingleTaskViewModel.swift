//
//  ViewModel.swift
//  async-location-swift-example
//
//  Created by Igor Shelopaev on 27.11.24.
//

import SwiftUI

/// A view model that manages a cancellable asynchronous task.
///
/// This view model provides a structure for managing asynchronous operations with proper error handling,
/// task cancellation, and state management for activity tracking. It is designed to work in a SwiftUI
/// environment using the `@Published` property wrapper to update the UI reactively.
///
/// - Note: The class is marked as `@MainActor` to ensure all interactions occur on the main thread.
@MainActor
@available(iOS 14.0, watchOS 7.0, *)
public final class SingleTaskViewModel<V: Sendable, E: Error>: ObservableObject {

    /// A type alias for the asynchronous operation to be performed.
    ///
    /// The operation is defined as a `@Sendable` asynchronous closure that can throw an error.
    public typealias Operation = @Sendable () async throws -> V?

    /// A type alias for an error handler.
    ///
    /// The error handler takes an optional `Error` and returns an optional error of type `E`.
    public typealias ErrorHandler = @Sendable (Error?) -> E?

    // MARK: - Public Properties

    /// The current error encountered during the operation, if any.
    @Published private(set) var error: E?

    /// The current value produced by the operation, if any.
    @Published private(set) var value: V?

    /// A Boolean indicating whether the operation is currently active.
    @Published var isActive = false

    // MARK: - Private Properties

    /// A custom error handler for processing errors.
    private let errorHandler: ErrorHandler?

    /// The currently running task, if any.
    private var task: Task<V?, Never>?

    // MARK: - Initialization

    /// Creates a new `TaskViewModel` instance.
    ///
    /// - Parameter errorHandler: A custom error handler to process errors. Defaults to `nil`.
    public init(errorHandler: ErrorHandler? = nil) {
        self.errorHandler = errorHandler
    }

    // MARK: - Public Methods

    /// Starts the asynchronous operation.
    ///
    /// This method initializes a new task, executes the provided operation, and manages its lifecycle.
    ///
    /// - Parameter operation: A `@Sendable` escaping closure representing the asynchronous operation to execute.
    @MainActor
    public func start(operation: @escaping Operation) {
        clean()
        isActive = true

        task = Task {
            do {
                value = try await operation()
            } catch {
                handle(error)
            }

            cancel()

            return value
        }
    }

    /// Resets the view model by clearing the current value and error.
    ///
    /// Use this method to prepare the view model for a new operation.
    public func clean() {
        error = nil
        value = nil
    }

    /// Cancels the currently running task.
    ///
    /// This method stops the task, clears the reference, and updates the `isActive` state.
    public func cancel() {
        isActive = false

        if let task {
            task.cancel()
        }

        task = nil
    }

    // MARK: - Private Methods

    /// Handles errors encountered during the operation.
    ///
    /// This method uses the custom error handler, if provided, or attempts to cast the error to type `E`.
    ///
    /// - Parameter error: The error encountered during the operation.
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
