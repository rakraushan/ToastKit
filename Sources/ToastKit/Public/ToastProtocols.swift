//
//  ToastProtocols.swift
//  ToastKit
//
//  Created by Raushan, Rakesh Kumar on 21/02/26.
//

// Sources/ToastKit/Public/ToastProtocols.swift
import Foundation

// MARK: - What the App Must Provide (App → SDK)

/// Protocol for app configuration
public protocol ToastConfigurationProvider: AnyObject {
    /// Maximum number of toasts to show at once
    var maxConcurrentToasts: Int { get }
    
    /// Default duration for toasts
    var defaultDuration: TimeInterval { get }
    
    /// Whether to allow toast stacking
    var allowStacking: Bool { get }
}

/// Protocol for app to provide custom styling
public protocol ToastStyleProvider: AnyObject {
    /// Background color for toast type
    func backgroundColor(for type: ToastType) -> ToastColor
    
    /// Text color for toast type
    func textColor(for type: ToastType) -> ToastColor
    
    /// Icon name for toast type (SF Symbol name)
    func iconName(for type: ToastType) -> String?
}

/// Protocol for app to receive events (SDK → App)
public protocol ToastEventObserver: AnyObject {
    /// Called when a toast is shown
    func toastDidShow(_ toast: Toast)
    
    /// Called when a toast is dismissed
    func toastDidDismiss(_ toast: Toast)
    
    /// Called when user taps on a toast
    func toastDidTap(_ toast: Toast)
}

// MARK: - Supporting Types

public enum ToastType: String, Sendable {
    case success
    case error
    case warning
    case info
}

public struct ToastColor: Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    // Preset colors
    public static let green = ToastColor(red: 0.2, green: 0.8, blue: 0.2)
    public static let red = ToastColor(red: 0.9, green: 0.2, blue: 0.2)
    public static let orange = ToastColor(red: 1.0, green: 0.6, blue: 0.0)
    public static let blue = ToastColor(red: 0.2, green: 0.6, blue: 1.0)
    public static let white = ToastColor(red: 1.0, green: 1.0, blue: 1.0)
    public static let black = ToastColor(red: 0.1, green: 0.1, blue: 0.1)
}

public struct Toast: Identifiable, Sendable {
    public let id: String
    public let message: String
    public let type: ToastType
    public let duration: TimeInterval
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        message: String,
        type: ToastType,
        duration: TimeInterval = 3.0
    ) {
        self.id = id
        self.message = message
        self.type = type
        self.duration = duration
        self.timestamp = Date()
    }
}
