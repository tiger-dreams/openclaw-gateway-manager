import SwiftUI

@main
struct MoltbotManagerApp: App {
    @StateObject private var configManager = ConfigManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(configManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
