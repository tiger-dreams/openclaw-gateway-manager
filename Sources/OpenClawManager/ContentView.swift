import SwiftUI

struct ContentView: View {
    @StateObject private var configManager = ConfigManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("OpenClaw Manager")
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
            Text("Port: \(port.formatted(.number.grouping(.never)))")
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
    @State private var orderedFallbacks: [String]

    init(configManager: ConfigManager, availableModels: [ModelDisplay], primaryModel: String, fallbackModels: [String]) {
        self.configManager = configManager
        self.availableModels = availableModels
        _selectedPrimary = State(initialValue: primaryModel)
        _orderedFallbacks = State(initialValue: fallbackModels)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Model Configuration")
                .font(.headline)

            // Primary Model
            VStack(alignment: .leading, spacing: 5) {
                Text("Primary Model")
                    .font(.caption)
                    .foregroundColor(.secondary)
                modelPicker(selection: $selectedPrimary)
                    .onChange(of: selectedPrimary) { newValue in
                        configManager.updatePrimaryModel(newValue)
                    }
            }

            Divider()

            // Fallback Models
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Fallback Models (Ordered)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        if let first = availableModels.first?.id {
                            orderedFallbacks.append(first)
                            saveFallbacks()
                        }
                    }) {
                        Label("Add", systemImage: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(orderedFallbacks.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1)st")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 25, alignment: .trailing)
                                
                                modelPicker(selection: $orderedFallbacks[index])
                                    .onChange(of: orderedFallbacks[index]) { _ in
                                        saveFallbacks()
                                    }
                                
                                Button(action: {
                                    orderedFallbacks.remove(at: index)
                                    saveFallbacks()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if orderedFallbacks.isEmpty {
                            Text("No fallback models selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.vertical, 5)
                }
                .frame(minHeight: 100, maxHeight: 250)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func saveFallbacks() {
        configManager.updateFallbackModels(orderedFallbacks)
    }

    private func modelPicker(selection: Binding<String>) -> some View {
        Picker("", selection: selection) {
            ForEach(availableModels, id: \.id) { model in
                HStack {
                    Image(systemName: model.isLocal ? "chip" : "cloud")
                        .foregroundColor(model.isLocal ? .blue : .green)
                    Text("\(model.displayName) (\(model.provider))")
                        .foregroundColor(model.isKnown ? .primary : .secondary)
                }
                .tag(model.id)
            }
        }
        .pickerStyle(.menu)
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
