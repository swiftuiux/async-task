//
//  State.swift
//  async-task
//
//  Created by Igor Shelopaev on 29.11.24.
//

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
        public var isActive: Bool {
            self == .active
        }
    }
}
