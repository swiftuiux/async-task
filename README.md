# Async Task Kit

### Please star the repository if you believe continuing the development of this package is worthwhile. This will help me understand which package deserves more effort.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftuiux%2Fasync-task%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swiftuiux/async-task)

**Async Task Kit** is a Swift package designed to simplify the management of cancellable asynchronous tasks. It provides reusable tools and patterns for handling asynchronous operations in SwiftUI applications.

## Examples in SwiftUI

Explore real examples of how to use this package in SwiftUI and how it can simplify the code:

1. [Async Location](https://github.com/swiftuiux/corelocation-manager-tracker-swift-apple-maps-example)
2. [Replicate Kit](https://github.com/swiftuiux/replicate-kit-example)
3. [OpenAI AsyncImage](https://github.com/swiftuiux/openai-async-image-swiftui)

## Overview

Async Task Kit provides tools to manage asynchronous tasks efficiently, with features such as:
- **State Management:** Monitor task progress, results, and errors using reactive properties.
- **Task Cancellation:** Cancel running tasks to free up resources when no longer needed.
- **Customizable Error Handling:** Define custom error-handling logic tailored to your application.
- **Seamless SwiftUI Integration:** Uses `@Published` properties for real-time UI updates or @observable is you can afford iOS17 or newer.
- **`Async.SingleTask`:** A view model for managing a single cancellable asynchronous task.

## Usage

### `Async.SingleTask`

The `Async.SingleTask` class simplifies managing a single asynchronous task. It tracks the task's result, error state, and activity status, making it ideal for use in SwiftUI views.

### Example: Fetching Data With Input
Below is an example of processing an input asynchronously using Async.SingleTask and producing a transformed output.

```swift
struct ProcessInputView: View {
    @StateObject private var viewModel = Async.SingleTask<Int, Error>()

    private var value: String? { viewModel.value }

    private var error: String? { viewModel.error?.localizedDescription }

    private var isActive: Bool { viewModel.state == .active }

    var body: some View {
        VStack {
            if let value {
                Text("Result: \(value)")
            } else if let error {
                Text("Error: \(error)")
            } else if isActive {
                ProgressView("Loading...")
            } else {
                Button("Process Input", action: processInput)
            }
        }
    }

    private func processInput() {
        viewModel.start(with: 21) { input in
            try await performAsyncProcessing(for: input)
        }
    }

    private func performAsyncProcessing(for input: Int) async throws -> Int {
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // Simulate a 1-second delay
        return input * 2
    }
}
```

### `Async.ObservableSingleTask`
For projects targeting iOS 17 and above, you can use Async.ObservableSingleTask, which leverages the new @Observable macro for more efficient state observation in SwiftUI.

### Example: Fetching Data Without Input Using ObservableSingleTask

```swift
@available(iOS 17.0, *)
struct ObservableCustomErrorView: View {

    @State private var viewModel = Async.ObservableSingleTask<String, CustomError>(errorMapper: customErrorMapper)

    var body: some View {
        VStack {
            if let value = viewModel.value {
                Text("Result: \(value)")
            } else if let error = viewModel.error {
                Text("Error: \(error)")
            } else if viewModel.state == .active {
                ProgressView("Loading...")
            } else {
                Button("Fetch Data", action: fetchData)
            }
        }
    }

    private func fetchData() {
        viewModel.start {
            try await performAsyncFetch()
        }
    }

    private func performAsyncFetch() async throws -> String {
        // Simulate an error
        throw NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to reach server"])
    } 
}

    enum CustomError: Error {
        case networkError(String)
    }

    let customErrorMapper: Async.ErrorMapper<CustomError> = { error in
        return .networkError(error.localizedDescription)
    }
```
