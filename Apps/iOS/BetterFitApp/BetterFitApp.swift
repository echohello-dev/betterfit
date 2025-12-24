import BetterFit
import SwiftUI

@main
struct BetterFitApp: App {
    let betterFit = BetterFit()

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

    var body: some Scene {
        WindowGroup {
            let theme = AppTheme.fromStorage(storedTheme)
            RootTabView(betterFit: betterFit, theme: theme)
                .tint(theme.accent)
                .preferredColorScheme(theme.preferredColorScheme)
        }
    }
}
