# Async Task Kit

### If you find this package helpful, please star the repository. Your feedback helps prioritize further development and enhancements.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Figor11191708%2Fasync-task%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/igor11191708/async-task)

**Async Task Kit** is a Swift package designed to simplify the management of cancellable asynchronous tasks. It provides reusable tools and patterns for handling asynchronous operations in SwiftUI applications.

---

## Examples in SwiftUI

Explore real-world examples of how to use this package in SwiftUI:

1. [Async Location Example](https://github.com/igor11191708/async-location-swift-example)
2. [Replicate Kit Example](https://github.com/igor11191708/replicate-kit-example)

---

## Overview

Async Task Kit provides tools to manage asynchronous tasks efficiently, with features such as:
- **State Management:** Monitor task progress, results, and errors using reactive properties.
- **Task Cancellation:** Cancel running tasks to free up resources when no longer needed.
- **Customizable Error Handling:** Define custom error-handling logic tailored to your application.
- **Seamless SwiftUI Integration:** Uses `@Published` properties for real-time UI updates. I decided to keep `@Published`, I think at this moment the world is not ready for iOS 17. 
- **`Async.SingleTask`:** A view model for managing a single cancellable asynchronous task.
---

## Usage

### `Async.SingleTask`

The `Async.SingleTask` class simplifies managing a single asynchronous task. It tracks the task's result, error state, and activity status, making it ideal for use in SwiftUI views.

---

### Example: Fetching Data Without Input

Below is an example of fetching data asynchronously using `Async.SingleTask` without requiring any input.

```swift

struct FetchDataView: View {
    @StateObject private var viewModel = Async.SingleTask<String, Error>()

    var body: some View {
        VStack {
            if let value = viewModel.value {
                Text("Result: \(value)")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            } else if viewModel.state.isActive {
                ProgressView("Loading...")
            } else {
                Button("Fetch Data", action: fetchData)
            }
        }
        .padding()
    }

    /// Initiates the task to fetch data.
    private func fetchData() {
        viewModel.start {
            try await performAsyncFetch()
        }
    }

    /// Simulates an asynchronous data fetch.
    private func performAsyncFetch() async throws -> String {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate a 2-second delay
        return "Hello, Async Task!"
    }
}
```
### Example: Fetching Data With Input
Below is an example of processing an input asynchronously using Async.SingleTask and producing a transformed output.

```swift
struct ProcessInputView: View {
    @StateObject private var viewModel = Async.SingleTask<Int, Error>()

    var body: some View {
        VStack {
            if let value = viewModel.value {
                Text("Result: \(value)")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            } else if viewModel.state.isActive {
                ProgressView("Processing...")
            } else {
                Button("Process Input", action: processInput)
            }
        }
        .padding()
    }

    /// Initiates the task to process the input value.
    private func processInput() {
        viewModel.start(with: 21) { input in
            try await performAsyncProcessing(for: input)
        }
    }

    /// Simulates an asynchronous operation that processes the input value.
    private func performAsyncProcessing(for input: Int) async throws -> Int {
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // Simulate a 1-second delay
        return input * 2
    }
}
```
