# ToasKit

## Installation

To install this package, import `https://github.com/rakraushan/ToastKit` in SPM.

## Usage Example

```Swift

// Simple usage
ToastManager.shared.success("Operation completed!")
ToastManager.shared.error("Something went wrong")
ToastManager.shared.warning("Please check your input")
ToastManager.shared.info("Here's some information")

// Custom duration
ToastManager.shared.show(
    message: "Custom toast",
    type: .info,
    duration: 5.0
)

```
