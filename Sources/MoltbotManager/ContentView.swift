import SwiftUI

struct ContentView: View {
    @StateObject private var configManager = ConfigManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Moltbot Manager")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            if let errorMessage = configManager.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.horizontal)
            }

            if let config = configManager.config {
                GatewayStatusView(
                    running: configManager.gatewayRunning,
                    port: config.gateway.port
                )
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                ModelSelectorView(
                    configManager: configManager,
                    availableModels: configManager.getAvailableModels(),
                    primaryModel: config.agents.defaults.model.primary,
                    fallbackModels: config.agents.defaults.model.fallbacks
                )
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                ActionButtonsView(
                    configManager: configManager
                )
                .padding(.horizontal)
            } else {
                ProgressView("Loading configuration...")
            }

            Spacer()
        }
        .frame(width: 500, height: 600)
        .onAppear {
            configManager.loadConfig()
            configManager.checkGatewayStatus()
        }
    }
}

struct GatewayStatusView: View {
    let running: Bool
    let port: Int

    var body: some View {
        HStack {
            Circle()
                .fill(running ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            Text(running ? "Gateway Running" : "Gateway Stopped")
                .font(.headline)
            Spacer()
            Text("Port: \(port)")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ModelSelectorView: View {
    @ObservedObject var configManager: ConfigManager
    let availableModels: [ModelDisplay]
    @State private var selectedPrimary: String
    @State private var selectedFallbacks: Set<String>

    init(configManager: ConfigManager, availableModels: [ModelDisplay], primaryModel: String, fallbackModels: [String]) {
        self.configManager = configManager
        self.availableModels = availableModels
        _selectedPrimary = State(initialValue: primaryModel)
        _selectedFallbacks = State(initialValue: Set(fallbackModels))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Model Configuration")
                .font(.headline)

            VStack(alignment: .leading, spacing: 5) {
                Text("Primary Model")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("", selection: $selectedPrimary) {
                    ForEach(availableModels, id: \.id) { model in
                        HStack {
                            Image(systemName: model.isLocal ? "chip" : "cloud")
                                .foregroundColor(model.isLocal ? .blue : .green)
                            Text(model.displayName)
                                .foregroundColor(model.isKnown ? .primary : .secondary)
                        }
                        .tag(model.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedPrimary) { newValue in
                    configManager.updatePrimaryModel(newValue)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Fallback Models (select multiple)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                List(availableModels, id: \.id, selection: $selectedFallbacks) { model in
                    HStack {
                        Image(systemName: selectedFallbacks.contains(model.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedFallbacks.contains(model.id) ? .green : .secondary)
                        Image(systemName: model.isLocal ? "chip" : "cloud")
                            .foregroundColor(model.isLocal ? .blue : .green)
                            .frame(width: 16)
                        Text(model.displayName)
                            .foregroundColor(model.isKnown ? .primary : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .frame(height: 250)
                .scrollContentBackground(.hidden)
                .listStyle(.bordered)
                .onChange(of: selectedFallbacks) { _ in
                    configManager.updateFallbackModels(Array(selectedFallbacks).sorted())
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ActionButtonsView: View {
    @ObservedObject var configManager: ConfigManager
    @State private var isRestarting = false

    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                configManager.checkGatewayStatus()
            }) {
                Label("Refresh Status", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)

            Button(action: {
                isRestarting = true
                _ = configManager.restartGateway()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isRestarting = false
                }
            }) {
                Label(isRestarting ? "Restarting..." : "Restart Gateway", systemImage: "power")
                    .frame(minWidth: 140)
            }
            .buttonStyle(.bordered)
            .disabled(isRestarting)
        }
        .padding()
    }
}
