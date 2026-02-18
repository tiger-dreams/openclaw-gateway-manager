import Foundation
import AppKit
import Network

public class ConfigManager: ObservableObject {
    @Published public var config: MoltbotConfig?
    @Published public var gatewayRunning: Bool = false
    @Published public var errorMessage: String?
    @Published public var configPath: String = ""
    @Published public var isActive: Bool = false

    private var activityCheckTimer: Timer?
    private var lastLogModification: Date?

    public init() {
        // Try to find config automatically
        // ... (init logic same as before but now public)
        if let foundPath = ConfigManager.findConfigPath() {
            configPath = foundPath
            loadConfig()
        } else {
             // Defer selection or default? 
             // Logic in original init was:
             // if found -> set, else select -> set, else default -> set.
             // But 'selectConfigPath' used NSOpenPanel which might be tricky in pure logic class or tests.
             // However, separating UI logic (NSOpenPanel) from Core logic is better.
             // For now, I'll keep it but wrap it safe.
             // Actually, for tests, we might want to inject path.
             configPath = "\(NSHomeDirectory())/.openclaw/openclaw.json"
             // attempting load
             loadConfig()
        }
    }
    
    // Helper to allow manual init for tests
    public init(path: String) {
        self.configPath = path
        loadConfig()
    }

    // Static helper to avoid instance dependency for finding path
    private static func findConfigPath() -> String? {
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

    public func selectConfig() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Select your openclaw.json config file"
        panel.title = "Choose Config File"

        if panel.runModal() == .OK, let url = panel.url {
            self.configPath = url.path
            loadConfig()
        }
    }

    public func loadConfig() {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let decoder = JSONDecoder()
            config = try decoder.decode(MoltbotConfig.self, from: data)
            errorMessage = nil
            // Verify partial update keys match? No need, JSONSerialization parses anything.
        } catch {
            errorMessage = "Failed to load config from \(configPath)\nDetails: \(error.localizedDescription)\n\(error)"
            print(error)
        }
    }

    private func modifyConfigJson(_ modification: (inout [String: Any]) -> Void) {
        let url = URL(fileURLWithPath: configPath)
        do {
            let data = try Data(contentsOf: url)
            guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                errorMessage = "Failed to parse config as JSON dictionary"
                return
            }
            
            modification(&json)
            
            let newData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
            try newData.write(to: url)
            
            // Reload to update UI
            loadConfig()
        } catch {
            errorMessage = "Failed to modify config: \(error.localizedDescription)"
            print(error)
        }
    }

    public func checkGatewayStatus() {
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
            case .waiting(_):
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

    public func restartGateway() -> Bool {
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

    public func getAvailableModels() -> [ModelDisplay] {
        guard let config = config else { return [] }

        var models: [ModelDisplay] = []

        // Added models tracking to prevent duplicates
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

    public func updatePrimaryModel(_ newModel: String) {
        modifyConfigJson { json in
            var agents = json["agents"] as? [String: Any] ?? [:]
            var defaults = agents["defaults"] as? [String: Any] ?? [:]
            var model = defaults["model"] as? [String: Any] ?? [:]
            
            model["primary"] = newModel
            
            defaults["model"] = model
            agents["defaults"] = defaults
            json["agents"] = agents
        }
    }

    public func updateFallbackModels(_ newFallbacks: [String]) {
        modifyConfigJson { json in
            var agents = json["agents"] as? [String: Any] ?? [:]
            var defaults = agents["defaults"] as? [String: Any] ?? [:]
            var model = defaults["model"] as? [String: Any] ?? [:]
            
            model["fallbacks"] = newFallbacks
            
            defaults["model"] = model
            agents["defaults"] = defaults
            json["agents"] = agents
        }
    }

    // MARK: - Activity Monitoring
    public func startActivityMonitoring() {
        // Check every 10 seconds
        activityCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.checkGatewayActivity()
        }
    }

    public func stopActivityMonitoring() {
        activityCheckTimer?.invalidate()
        activityCheckTimer = nil
    }

    private func checkGatewayActivity() {
        guard gatewayRunning else {
            self.isActive = false
            return
        }

        // Find the latest log file in /tmp/openclaw/
        let logDir = "/tmp/openclaw"
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: logDir) else {
            self.isActive = false
            return
        }

        do {
            let files = try fileManager.contentsOfDirectory(atPath: logDir)
            let logFiles = files.filter { $0.hasPrefix("openclaw-") && $0.hasSuffix(".log") }

            if let latestFile = logFiles.sorted().last {
                let filePath = "\(logDir)/\(latestFile)"
                let attributes = try fileManager.attributesOfItem(atPath: filePath)

                if let modificationDate = attributes[.modificationDate] as? Date {
                    // If log was modified in the last 10 seconds, consider it active
                    let timeSinceModification = Date().timeIntervalSince(modificationDate)
                    self.isActive = timeSinceModification < 10.0
                } else {
                    self.isActive = false
                }
            } else {
                self.isActive = false
            }
        } catch {
            print("Error checking log activity: \(error)")
            self.isActive = false
        }
    }
}
