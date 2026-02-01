import Foundation
import AppKit

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
                configPath = "/Users/tiger/.moltbot/moltbot.json"
            }
        }
        loadConfig()
    }

    private func findConfigPath() -> String? {
        // Check current directory
        if FileManager.default.fileExists(atPath: "./moltbot.json") {
            return "./moltbot.json"
        }

        // Check ~/moltbot
        let homeMoltbot = "\(NSHomeDirectory())/moltbot/moltbot.json"
        if FileManager.default.fileExists(atPath: homeMoltbot) {
            return homeMoltbot
        }

        // Check ~/.moltbot
        let homeDotMoltbot = "\(NSHomeDirectory())/.moltbot/moltbot.json"
        if FileManager.default.fileExists(atPath: homeDotMoltbot) {
            return homeDotMoltbot
        }

        return nil
    }

    private func selectConfigPath() -> String? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Select your moltbot.json config file"
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
            errorMessage = "Failed to load config from \(configPath)"
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
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", "ps aux | grep -i 'moltbot-gateway' | grep -v grep | wc -l"]

            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"

            DispatchQueue.main.async {
                self.gatewayRunning = Int(output) ?? 0 > 0
            }
        }
    }

    func restartGateway() -> Bool {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", "pkill -f 'moltbot-gateway' && sleep 1 && moltbot-gateway > /dev/null 2>&1 &"]
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

        // Add models from providers
        for (providerName, provider) in config.models.providers {
            for model in provider.models {
                let providerDisplay = CloudModels.knownProviders[providerName] ?? providerName
                let displayName = model.name
                let isLocal = providerName == "ollama"
                let isKnown = !isLocal

                models.append(ModelDisplay(
                    id: "\(providerName)/\(model.id)",
                    displayName: displayName,
                    provider: providerDisplay,
                    isLocal: isLocal,
                    isKnown: isKnown
                ))
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

                    models.append(ModelDisplay(
                        id: aliasKey, // Use the alias key as ID
                        displayName: displayName,
                        provider: providerDisplay,
                        isLocal: isLocal,
                        isKnown: isKnown
                    ))
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
