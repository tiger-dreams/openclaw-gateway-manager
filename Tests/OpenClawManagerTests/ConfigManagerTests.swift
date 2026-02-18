import XCTest
import OpenClawKit

final class ConfigManagerTests: XCTestCase {
    
    var configManager: ConfigManager!
    var tempConfigPath: String!
    
    override func setUp() {
        super.setUp()
        configManager = ConfigManager()
        
        // Create a temporary config file
        let tempDir = FileManager.default.temporaryDirectory
        // Use a unique filename
        let uniqueName = "test_config_\(UUID().uuidString).json"
        let tempUrl = tempDir.appendingPathComponent(uniqueName)
        tempConfigPath = tempUrl.path
        configManager.configPath = tempConfigPath
        
        // Create initial dummy config with extra fields (Slack, Discord, etc.)
        // We need to construct a valid JSON matching MoltbotConfig structure
        // Note: The structure in the test MUST match the actual Codable struct requirements.
        let initialConfig = """
        {
            "meta": { "lastTouchedVersion": "1.0.0", "lastTouchedAt": "" },
            "wizard": { "lastRunAt": "", "lastRunVersion": "", "lastRunCommand": "", "lastRunMode": "", "features": [] },
            "auth": { "profiles": {} },
            "models": { "mode": "local", "providers": {} },
            "agents": {
                "defaults": {
                    "model": {
                        "primary": "gpt-4",
                        "fallbacks": ["gpt-3.5-turbo"]
                    }
                }
            },
            "tools": { "web": null },
            "messages": { "ackReactionScope": null },
            "commands": { "native": null, "nativeSkills": null },
            "hooks": { "internal": null },
            "channels": {
                "discord": {
                    "enabled": true,
                    "token": "SECRET_DISCORD_TOKEN",
                    "groupPolicy": "allow_all",
                    "dm": null
                },
                "slack": {
                    "enabled": true,
                    "botToken": "SECRET_SLACK_TOKEN",
                    "appToken": "SECRET_APP_TOKEN",
                    "signingSecret": "SECRET_SIGNING",
                    "dm": null
                },
                "telegram": null
            },
            "gateway": {
                "port": 8080,
                "mode": "standard",
                "bind": "0.0.0.0",
                "auth": { "mode": "none", "token": "" },
                "tailscale": { "mode": "off", "resetOnExit": false }
            },
            "plugins": {
                "entries": {
                    "custom-plugin": { "enabled": true }
                }
            }
        }
        """
        
        do {
             try initialConfig.write(to: tempUrl, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to write temp config: \(error)")
        }
        
        configManager.loadConfig()
    }
    
    override func tearDown() {
        if let path = tempConfigPath {
            try? FileManager.default.removeItem(atPath: path)
        }
        super.tearDown()
    }
    
    func testUpdatePrimaryModel_PreservesOtherFields() {
        // Given
        // We need to decode manually or access via configManager.config
        // However, ConfigManager might need to be adjusted if it doesn't load immediately or sync.
        // loadConfig() is synchronous in the implementation I saw.
        
        // Check if config loaded
        XCTAssertNotNil(configManager.config, "Config should differ from nil")
        
        // When
        configManager.updatePrimaryModel("claude-3-opus")
        
        // Then
        // Reload config from disk to verify persistence
        configManager.loadConfig()
        
        XCTAssertEqual(configManager.config?.agents.defaults.model.primary, "claude-3-opus", "Primary model should be updated")
        
        // CRITICAL: Verify other fields are preserved
        // Note: access specific fields.
        XCTAssertEqual(configManager.config?.channels.discord?.token, "SECRET_DISCORD_TOKEN", "Discord token should be preserved")
        XCTAssertEqual(configManager.config?.channels.slack?.botToken, "SECRET_SLACK_TOKEN", "Slack bot token should be preserved")
       
        // Verify plugin preservation if possible (Plugins struct might be optional or map)
        XCTAssertEqual(configManager.config?.plugins?.entries?["custom-plugin"]?.enabled, true, "Plugins should be preserved")
    }
    
    func testUpdateFallbackModels_PreservesOtherFields() {
        // Given
        XCTAssertEqual(configManager.config?.agents.defaults.model.fallbacks, ["gpt-3.5-turbo"])
        
        // When
        configManager.updateFallbackModels(["claude-3-sonnet", "gemini-pro"])
        
        // Then
        configManager.loadConfig()
        
        XCTAssertEqual(configManager.config?.agents.defaults.model.fallbacks, ["claude-3-sonnet", "gemini-pro"], "Fallbacks should be updated")
        XCTAssertEqual(configManager.config?.channels.discord?.token, "SECRET_DISCORD_TOKEN", "Discord token should be preserved")
    }
}
