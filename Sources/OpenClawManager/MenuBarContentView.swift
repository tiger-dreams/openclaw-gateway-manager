import SwiftUI
import OpenClawKit

struct MenuBarContentView: View {
    @ObservedObject var configManager: ConfigManager
    @State private var showingSettingsSheet = false

    var body: some View {
        VStack(spacing: 12) {
            // Gateway 상태
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(statusText)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
            }

            Divider()

            // 현재 모델 표시
            if let config = configManager.config {
                HStack {
                    Image(systemName: "cpu")
                        .foregroundColor(.secondary)
                    Text("Model:")
                    Spacer()
                    Text(getModelDisplayName(config.agents.defaults.model.primary))
                        .foregroundColor(.secondary)
                        .font(.system(size: 11))
                }

                Divider()
            }

            // 액션 버튼들
            Button(action: {
                configManager.checkGatewayStatus()
            }) {
                Label("Refresh Status", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)

            Button(action: {
                showingSettingsSheet = true
            }) {
                Label("Open Settings", systemImage: "gearshape")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)

            Button(action: {
                _ = configManager.restartGateway()
            }) {
                Label("Restart Gateway", systemImage: "arrow.clockwise.circle")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
        .padding()
        .frame(width: 200)
        .sheet(isPresented: $showingSettingsSheet) {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.headline)

                if let config = configManager.config {
                    Text("Current Model: \(getModelDisplayName(config.agents.defaults.model.primary))")
                        .font(.subheadline)

                    Divider()

                    HStack {
                        Text("Port:")
                        Spacer()
                        Text("\(config.gateway.port)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Status:")
                        Spacer()
                        if configManager.isActive {
                            Text("Active")
                                .foregroundColor(.green)
                        } else {
                            Text("Idle")
                                .foregroundColor(.orange)
                        }
                    }

                    Divider()

                    Button("Close") {
                        showingSettingsSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 400, height: 300)
        }
        .onAppear {
            configManager.checkGatewayStatus()
        }
    }

    private var statusColor: Color {
        if !configManager.gatewayRunning {
            return .red
        } else if configManager.isActive {
            return .green
        } else {
            return .orange
        }
    }

    private var statusText: String {
        if !configManager.gatewayRunning {
            return "Stopped"
        } else if configManager.isActive {
            return "Active"
        } else {
            return "Idle"
        }
    }

    private func getModelDisplayName(_ modelId: String) -> String {
        let modelMap: [String: String] = [
            "gemini-3-pro-preview": "Gemini 3.0 Pro",
            "gemini-3-flash": "Gemini 3.0 Flash",
            "claude-opus-4-5": "Claude Opus 4.5",
            "claude-sonnet-4-5": "Claude Sonnet 4.5",
            "glm-4.7": "GLM-4.7",
            "gpt-4o-mini": "GPT-4o Mini"
        ]

        // provider/model 형식 처리
        if let slashIndex = modelId.firstIndex(of: "/") {
            let modelOnly = String(modelId[modelId.index(after: slashIndex)...])
            return modelMap[modelOnly.lowercased()] ?? modelOnly
        }

        return modelMap[modelId.lowercased()] ?? modelId
    }
}
