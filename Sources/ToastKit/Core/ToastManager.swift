//
//  ToastManager.swift
//  ToastKit
//
//  Created by Raushan, Rakesh Kumar on 21/02/26.
//

// Sources/ToastKit/Core/ToastManager.swift
import Foundation

/// Main Toast Manager - configured through dependency injection
public final class ToastManager: @unchecked Sendable {
    
    // MARK: - Singleton
    
    public static let shared = ToastManager()
    
    // MARK: - Dependencies (Injected by App)
    
    private weak var configProvider: ToastConfigurationProvider?
    private weak var styleProvider: ToastStyleProvider?
    private weak var eventObserver: ToastEventObserver?
    
    // MARK: - Internal State
    
    private var activeToasts: [Toast] = []
    private var isConfigured = false
    
    private init() {}
    
    // MARK: - Configuration
    
    /// Configure the Toast Manager with dependencies
    public func configure(
        configProvider: ToastConfigurationProvider,
        styleProvider: ToastStyleProvider,
        eventObserver: ToastEventObserver? = nil
    ) {
        self.configProvider = configProvider
        self.styleProvider = styleProvider
        self.eventObserver = eventObserver
        self.isConfigured = true
        
        print("🍞 ToastKit configured successfully")
    }
    
    // MARK: - Show Toasts
    
    /// Show a toast message
    public func show(
        message: String,
        type: ToastType = .info,
        duration: TimeInterval? = nil
    ) {
        guard isConfigured else {
            print("❌ ToastKit not configured - call configure() first")
            return
        }
        
        // Use provided duration or get default from config
        let finalDuration = duration ?? configProvider?.defaultDuration ?? 3.0
        
        let toast = Toast(
            message: message,
            type: type,
            duration: finalDuration
        )
        
        // Check if we can show more toasts
        let maxToasts = configProvider?.maxConcurrentToasts ?? 3
        let allowStacking = configProvider?.allowStacking ?? true
        
        if !allowStacking && !activeToasts.isEmpty {
            print("⚠️ Toast stacking disabled - dismissing existing toast")
            dismissAll()
        }
        
        if activeToasts.count >= maxToasts {
            print("⚠️ Max toasts reached - dismissing oldest")
            if let oldest = activeToasts.first {
                dismiss(toast: oldest)
            }
        }
        
        // Add to active toasts
        activeToasts.append(toast)
        
        print("🍞 Showing toast: [\(type.rawValue)] \(message)")
        
        // Notify observer
        eventObserver?.toastDidShow(toast)
        
        // Auto-dismiss after duration (supports older OS versions)
        let delaySeconds = toast.duration
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                // Use self to ensure we dismiss on the current manager instance
                self?.dismiss(toast: toast)
            }
        } else {
            // Fallback for older platforms without Swift Concurrency
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
                self?.dismiss(toast: toast)
            }
        }
    }
    
    /// Show success toast
    public func success(_ message: String, duration: TimeInterval? = nil) {
        show(message: message, type: .success, duration: duration)
    }
    
    /// Show error toast
    public func error(_ message: String, duration: TimeInterval? = nil) {
        show(message: message, type: .error, duration: duration)
    }
    
    /// Show warning toast
    public func warning(_ message: String, duration: TimeInterval? = nil) {
        show(message: message, type: .warning, duration: duration)
    }
    
    /// Show info toast
    public func info(_ message: String, duration: TimeInterval? = nil) {
        show(message: message, type: .info, duration: duration)
    }
    
    // MARK: - Dismiss Toasts
    
    /// Dismiss specific toast
    public func dismiss(toast: Toast) {
        guard let index = activeToasts.firstIndex(where: { $0.id == toast.id }) else {
            return
        }
        
        activeToasts.remove(at: index)
        
        print("🍞 Dismissed toast: \(toast.message)")
        
        // Notify observer
        eventObserver?.toastDidDismiss(toast)
    }
    
    /// Dismiss all toasts
    public func dismissAll() {
        let toastsToDismiss = activeToasts
        activeToasts.removeAll()
        
        for toast in toastsToDismiss {
            eventObserver?.toastDidDismiss(toast)
        }
        
        print("🍞 Dismissed all toasts")
    }
    
    // MARK: - Tap Handling
    
    /// Handle toast tap
    public func handleTap(toast: Toast) {
        print("👆 Toast tapped: \(toast.message)")
        
        // Notify observer
        eventObserver?.toastDidTap(toast)
        
        // Dismiss when tapped
        dismiss(toast: toast)
    }
    
    // MARK: - Getters
    
    /// Get current active toasts
    public func getActiveToasts() -> [Toast] {
        return activeToasts
    }
    
    /// Get style for toast type
    public func getStyle(for type: ToastType) -> (background: ToastColor, text: ToastColor, icon: String?) {
        guard let styleProvider = styleProvider else {
            // Default styles if no provider
            return (background: .blue, text: .white, icon: nil)
        }
        
        return (
            background: styleProvider.backgroundColor(for: type),
            text: styleProvider.textColor(for: type),
            icon: styleProvider.iconName(for: type)
        )
    }
}

