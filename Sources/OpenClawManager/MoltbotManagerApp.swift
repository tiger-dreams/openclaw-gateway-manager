import SwiftUI

@main
struct MoltbotManagerApp: App {
    @StateObject private var configManager = ConfigManager()

    var body: some Scene {
        WindowGroup("OpenClaw Manager") {
            ContentView()
                .environmentObject(configManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
