//
//  TaskProperty.swift
//  async-task
//
//  Created by Igor Shelopaev  on 29.11.24.
//

extension Async {
    
    /// An enumeration representing the properties of an asynchronous task that can be reset.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    enum TaskProperty {

        /// Represents the `error` property of a task.
        case error

        /// Represents the `value` property of a task.
        case value
    }
}
