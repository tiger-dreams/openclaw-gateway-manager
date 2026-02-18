import SwiftUI
import OpenClawKit

struct MenuBarIconView: View {
    @ObservedObject var configManager: ConfigManager

    var body: some View {
        if configManager.gatewayRunning && configManager.isActive {
            Image(systemName: "cpu.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue)
        } else if configManager.gatewayRunning {
            Image(systemName: "cpu.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.green)
        } else {
            Image(systemName: "cpu")
                .foregroundStyle(.secondary)
        }
    }
}

@main
struct MoltbotManagerApp: App {
    @StateObject private var configManager = ConfigManager()

    init() {
        // Activity monitoring is started in ConfigManager.init via onAppear workaround
    }

    var body: some Scene {
        WindowGroup("OpenClaw Manager") {
            ContentView()
                .environmentObject(configManager)
                .onAppear {
                    configManager.startActivityMonitoring()
                    configManager.checkGatewayStatus()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        // MenuBarExtra로 상태바 아이콘 구현
        MenuBarExtra {
            // 메뉴 팝업
            MenuBarContentView(configManager: configManager)
        } label: {
            // 별도 View로 분리하여 @ObservedObject가 상태 변경을 감지하도록 함
            MenuBarIconView(configManager: configManager)
        }
        .menuBarExtraStyle(.window)
    }
}
