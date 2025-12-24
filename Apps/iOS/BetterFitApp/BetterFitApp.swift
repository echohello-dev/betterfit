import BetterFit
import SwiftUI

@main
struct BetterFitApp: App {
    let betterFit = BetterFit()

    var body: some Scene {
        WindowGroup {
            ContentView(betterFit: betterFit)
        }
    }
}
