import Foundation

struct MoltbotConfig: Codable {
    let meta: Meta
    let wizard: Wizard
    let auth: Auth
    let models: Models
    var agents: Agents
    let tools: Tools
    let messages: Messages
    let commands: Commands
    let hooks: Hooks
    let channels: Channels
    let gateway: Gateway

    struct Meta: Codable {
        let lastTouchedVersion: String
        let lastTouchedAt: String
    }

    struct Wizard: Codable {
        let lastRunAt: String
        let lastRunVersion: String
        let lastRunCommand: String
        let lastRunMode: String
    }

    struct Auth: Codable {
        let profiles: [String: Profile]
        struct Profile: Codable {
            let provider: String
            let mode: String
        }
    }

    struct Models: Codable {
        let mode: String
        let providers: [String: Provider]
        struct Provider: Codable {
            let baseUrl: String?
            let apiKey: String?
            let api: String?
            let models: [Model]
            struct Model: Codable {
                let id: String
                let name: String
                let reasoning: Bool?
                let input: [String]?
                let cost: Cost?
                let contextWindow: Int?
                let maxTokens: Int?
            }
            struct Cost: Codable {
                let input: Double
                let output: Double
                let cacheRead: Double
                let cacheWrite: Double
            }
        }
    }

    struct CloudModels: Codable {
        static let knownProviders: [String: String] = [
            "anthropic": "Anthropic",
            "google-gemini-cli": "Google Gemini",
            "openai": "OpenAI",
            "openrouter": "OpenRouter",
            "groq": "Groq",
            "zai": "Z.ai"
        ]
    }

    struct ModelAliases: Codable {
        static let knownAliases: [String: String] = [
            "anthropic/claude-opus-4-5": "Opus",
            "anthropic/claude-sonnet-4-5": "Sonnet",
            "google-gemini-cli/gemini-3-pro-preview": "3.0 Pro"
        ]
    }

    struct Agents: Codable {
        var defaults: Defaults
        struct Defaults: Codable {
            var model: ModelConfig
            var models: [String: ModelAlias]?
            var workspace: String?
            struct ModelConfig: Codable {
                var primary: String
                var fallbacks: [String]
            }
            struct ModelAlias: Codable {
                let alias: String?
            }
        }
    }

    struct Tools: Codable {
        let web: Web?
        struct Web: Codable {
            let search: Search?
            struct Search: Codable {
                let apiKey: String
            }
        }
    }

    struct Messages: Codable {
        let ackReactionScope: String?
    }

    struct Commands: Codable {
        let native: String?
        let nativeSkills: String?
    }

    struct Hooks: Codable {
        let `internal`: InternalConfig?
        struct InternalConfig: Codable {
            let enabled: Bool
            let entries: [String: Entry]?
            struct Entry: Codable {
                let enabled: Bool
            }
        }
    }

    struct Channels: Codable {
        let telegram: Telegram?
        struct Telegram: Codable {
            let enabled: Bool
            let dmPolicy: String
            let botToken: String
            let allowFrom: [String]
            let groupPolicy: String
            let streamMode: String
        }
    }

    struct Gateway: Codable {
        let port: Int
        let mode: String
        let bind: String
        let auth: AuthConfig
        let tailscale: Tailscale
        struct AuthConfig: Codable {
            let mode: String
            let token: String
        }
        struct Tailscale: Codable {
            let mode: String
            let resetOnExit: Bool
        }
    }
}
