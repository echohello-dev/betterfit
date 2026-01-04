import BetterFit
import SwiftUI
import UIKit

/// AppDelegate to handle OAuth URL callbacks from Google Sign In
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle OAuth callback URLs with scheme "betterfit://"
        guard url.scheme == "betterfit" else {
            return false
        }

        // Post notification that auth service can observe
        NotificationCenter.default.post(
            name: .authCallbackReceived,
            object: nil,
            userInfo: ["url": url]
        )

        return true
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let authCallbackReceived = Notification.Name("AuthCallbackReceived")
}
