# Async task management

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Figor11191708%2Fasync-task%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/igor11191708/async-task)

It's a start of the Swift package providing tools and types for managing asynchronous tasks. This package is designed to simplify the handling of cancellable asynchronous operations in SwiftUI applications by offering reusable view models and patterns.

## SwiftUI example of using package
[async-location-swift-example](https://github.com/The-Igor/async-location-swift-example)

## Overview

`AsyncTaskManager` provides a set of tools for managing asynchronous tasks with support for:
- **Error handling:** Handle errors gracefully with custom error handlers.
- **State management:** Track the progress and result of tasks using reactive properties.
- **Task cancellation:** Cancel tasks when they are no longer needed, freeing up resources.

## Features

- **`SingleTaskViewModel`:** A view model for managing a single cancellable asynchronous task.
- **Error-handling extensibility:** Pass a custom error handler to adapt to your application's requirements.
- **Integration with SwiftUI:** Leverage the `@Published` property wrapper for UI updates.

## Usage

### `SingleTaskViewModel`

The `SingleTaskViewModel` class manages a cancellable asynchronous operation. It tracks the operation's result, error, and activity state.

#### Properties

- `value`: The result of the operation, if successful.
- `error`: An error of type `E` if the operation fails.
- `isActive`: Indicates whether the task is currently running.

#### Methods

- `start(operation:)`: Starts the asynchronous task.
- `cancel()`: Cancels the currently running task.

#### Example

```swift
struct ExampleView: View {
    @StateObject private var viewModel = SingleTaskViewModel<String, Error>()
    
    var body: some View {
        VStack {
            if let value = viewModel.value {
                Text("Result: \(value)")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            } else if viewModel.isActive {
                ProgressView("Loading...")
            } else {
                Button("Fetch Data") {
                    viewModel.start {
                        // Simulate an async task
                        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                        return "Hello, World!"
                    }
                }
            }
        }
        .padding()
    }
}
``` 
