//
//  Type.swift
//  async-task
//
//  Created by Igor Shelopaev on 29.11.24.
//

extension Async {
    
    /// A closure type for handling errors.
    ///
    /// This closure processes an `Error` and returns an optional custom error of type `E`.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public typealias ErrorMapper<E: Error & Sendable> = @Sendable (Error) -> E?
    
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
    public typealias Mapper<Input: Sendable, Output: Sendable> = @Sendable (Input) async throws -> Output

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
    public typealias Producer<Output: Sendable> = @Sendable () async throws -> Output
}
