import Foundation
import AppKit
import Network

class ConfigManager: ObservableObject {
    @Published var config: MoltbotConfig?
    @Published var gatewayRunning: Bool = false
    @Published var errorMessage: String?
    @Published var configPath: String = ""

    init() {
        // Try to find config automatically
        if let foundPath = findConfigPath() {
            configPath = foundPath
        } else {
            // Try to select config if not found
            if let selectedPath = selectConfigPath() {
                configPath = selectedPath
            } else {
                configPath = "\(NSHomeDirectory())/.openclaw/openclaw.json"
            }
        }
        loadConfig()
    }

    private func findConfigPath() -> String? {
        // Check current directory
        if FileManager.default.fileExists(atPath: "./openclaw.json") {
            return "./openclaw.json"
        }

        // Check ~/.openclaw
        let homeOpenclaw = "\(NSHomeDirectory())/.openclaw/openclaw.json"
        if FileManager.default.fileExists(atPath: homeOpenclaw) {
            return homeOpenclaw
        }

        // Check ~/.moltbot
        let homeMoltbot = "\(NSHomeDirectory())/.moltbot/openclaw.json"
        if FileManager.default.fileExists(atPath: homeMoltbot) {
            return homeMoltbot
        }

        // Check ~/.moltbot (legacy filename)
        let homeMoltbotLegacy = "\(NSHomeDirectory())/.moltbot/moltbot.json"
        if FileManager.default.fileExists(atPath: homeMoltbotLegacy) {
            return homeMoltbotLegacy
        }

        return nil
    }

    private func selectConfigPath() -> String? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Select your openclaw.json config file"
        panel.title = "Choose Config File"

        if panel.runModal() == .OK, let url = panel.url {
            return url.path
        }

        return nil
    }

    func loadConfig() {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let decoder = JSONDecoder()
            config = try decoder.decode(MoltbotConfig.self, from: data)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load config from \(configPath)\nDetails: \(error.localizedDescription)\n\(error)"
            print(error)
        }
    }

    func saveConfig() {
        guard let config = config else { return }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            try data.write(to: URL(fileURLWithPath: configPath))
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save config: \(error.localizedDescription)"
            print(error)
        }
    }

    func checkGatewayStatus() {
        guard let config = config else {
            self.gatewayRunning = false
            return
        }

        let host = NWEndpoint.Host("127.0.0.1")
        let port = NWEndpoint.Port(integerLiteral: UInt16(config.gateway.port))
        let connection = NWConnection(host: host, port: port, using: .tcp)

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                DispatchQueue.main.async {
                    self.gatewayRunning = true
                    connection.cancel()
                }
            case .failed(_):
                DispatchQueue.main.async {
                    self.gatewayRunning = false
                    connection.cancel()
                }
            case .waiting(let error):
                // Waiting means it can't connect immediately (e.g. refused)
                DispatchQueue.main.async {
                   self.gatewayRunning = false
                   connection.cancel()
                }
            default:
                break
            }
        }
        
        connection.start(queue: .global())
    }

    func restartGateway() -> Bool {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", "pkill -f 'openclaw gateway' && sleep 1 && openclaw gateway > /dev/null 2>&1 &"]
            task.launch()
            task.waitUntilExit()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.checkGatewayStatus()
            }
        }

        return true
    }



    func getAvailableModels() -> [ModelDisplay] {
        guard let config = config else { return [] }

        var models: [ModelDisplay] = []

        // ADded models tracking to prevent duplicates
        var addedIds = Set<String>()

        // Add models from providers
        for (providerName, provider) in config.models.providers {
            for model in provider.models {
                let providerDisplay = CloudModels.knownProviders[providerName] ?? providerName
                let displayName = model.name
                let isLocal = providerName == "ollama"
                let isKnown = !isLocal

                let id = "\(providerName)/\(model.id)"
                models.append(ModelDisplay(
                    id: id,
                    displayName: displayName,
                    provider: providerDisplay,
                    isLocal: isLocal,
                    isKnown: isKnown
                ))
                addedIds.insert(id)
            }
        }

        // Add alias models (e.g., claude-opus-4-5, gemini-3-pro-preview)
        if let aliases = config.agents.defaults.models {
            for (aliasKey, _) in aliases {
                // Extract provider and model from alias key (e.g., "anthropic/claude-opus-4-5")
                if let slashIndex = aliasKey.firstIndex(of: "/") {
                    let providerName = String(aliasKey[..<slashIndex])
                    let modelId = String(aliasKey[aliasKey.index(after: slashIndex)...])

                    // Get display name from model ID
                    let displayName = CloudModels.getDisplayName(from: modelId)

                    let providerDisplay = CloudModels.knownProviders[providerName] ?? providerName
                    let isLocal = false
                    let isKnown = true

                    let id = aliasKey
                    // SKIP if already added via providers
                    if !addedIds.contains(id) {
                        models.append(ModelDisplay(
                            id: id,
                            displayName: displayName,
                            provider: providerDisplay,
                            isLocal: isLocal,
                            isKnown: isKnown
                        ))
                        addedIds.insert(id)
                    }
                }
            }
        }

        return models.sorted { $0.displayName < $1.displayName }
    }

    func updatePrimaryModel(_ newModel: String) {
        var mutableConfig = config
        mutableConfig?.agents.defaults.model.primary = newModel
        config = mutableConfig
        saveConfig()
    }

    func updateFallbackModels(_ newFallbacks: [String]) {
        var mutableConfig = config
        mutableConfig?.agents.defaults.model.fallbacks = newFallbacks
        config = mutableConfig
        saveConfig()
    }
}
