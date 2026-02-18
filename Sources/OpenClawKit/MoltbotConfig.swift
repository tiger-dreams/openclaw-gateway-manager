import Foundation

public struct MoltbotConfig: Codable {
    public let meta: Meta? // Made optional
    public let wizard: Wizard? // Made optional
    public let auth: Auth? // Made optional
    public let models: Models // Core (used for model list)
    public var agents: Agents // Core (used for primary/fallback)
    public let tools: Tools? // Made optional
    public let messages: Messages? // Made optional
    public let commands: Commands? // Made optional
    public let hooks: Hooks? // Made optional
    public let channels: Channels? // Made optional
    public let gateway: Gateway // Core (used for port check)
    public let plugins: Plugins? // Already optional
    
    // Also added robust decoding for other possible fields
    // But since `models`, `agents`, `gateway` are critical, we keep them required.
    // If they change drastically, the app indeed cannot function properly anyway.

    public struct Meta: Codable {
        public let lastTouchedVersion: String?
        public let lastTouchedAt: String?
    }

    public struct Wizard: Codable {
        public let lastRunAt: String?
        public let lastRunVersion: String?
        public let lastRunCommand: String?
        public let lastRunMode: String?
    }

    public struct Auth: Codable {
        public let profiles: [String: Profile]?
        public struct Profile: Codable {
            public let provider: String?
            public let mode: String?
        }
    }

    public struct Models: Codable {
        public let mode: String?
        public let providers: [String: Provider]
        public struct Provider: Codable {
            public let baseUrl: String?
            public let apiKey: String?
            public let api: String?
            public let models: [Model]
            public struct Model: Codable {
                public let id: String
                public let name: String
                public let reasoning: Bool?
                public let input: [String]?
                public let cost: Cost?
                public let contextWindow: Int?
                public let maxTokens: Int?
            }
            public struct Cost: Codable {
                public let input: Double
                public let output: Double
                public let cacheRead: Double
                public let cacheWrite: Double
            }
        }
    }

    public struct Agents: Codable {
        public var defaults: Defaults
        public struct Defaults: Codable {
            public var model: ModelConfig
            public var models: [String: ModelAlias]?
            public var workspace: String?
            public struct ModelConfig: Codable {
                public var primary: String
                public var fallbacks: [String]
            }
            public struct ModelAlias: Codable {
                public let alias: String?
            }
        }
    }

    public struct Tools: Codable {
        public let web: Web?
        public struct Web: Codable {
            public let search: Search?
            public struct Search: Codable {
                public let apiKey: String
            }
        }
    }

    public struct Messages: Codable {
        public let ackReactionScope: String?
    }

    public struct Commands: Codable {
        public let native: String?
        public let nativeSkills: String?
    }

    public struct Hooks: Codable {
        public let `internal`: InternalConfig?
        public struct InternalConfig: Codable {
            public let enabled: Bool
            public let entries: [String: Entry]?
            public struct Entry: Codable {
                public let enabled: Bool
            }
        }
    }

    public struct Channels: Codable {
        public let telegram: Telegram?
        public let discord: Discord?
        public let slack: Slack?

        public struct Telegram: Codable {
            public let enabled: Bool
            public let dmPolicy: String?
            public let botToken: String
            public let allowFrom: [String]?
            public let groupPolicy: String?
            public let streamMode: String?
        }

        public struct Discord: Codable {
            public let enabled: Bool
            public let token: String
            public let groupPolicy: String?
            public let dm: DM? // Made DM itself optional

            public struct DM: Codable {
                public let policy: String?
                public let allowFrom: [String]?
            }
        }

        public struct Slack: Codable {
            public let enabled: Bool
            public let botToken: String
            public let appToken: String?
            public let signingSecret: String?
            public let dm: SlackDM?
            // Added optional fields for future proofing/backward comp
            public let dmPolicy: String?
            public let groupPolicy: String?
            public let userTokenReadOnly: Bool?

            public struct SlackDM: Codable {
                public let policy: String?
                public let allowFrom: [String]?
            }
        }
    }

    public struct Gateway: Codable {
        public let port: Int
        public let mode: String?
        public let bind: String?
        public let auth: AuthConfig?
        public let tailscale: Tailscale?
        
        public struct AuthConfig: Codable {
            public let mode: String?
            public let token: String?
        }
        public struct Tailscale: Codable {
            public let mode: String?
            public let resetOnExit: Bool?
        }
    }

    public struct Plugins: Codable {
        public let entries: [String: PluginEntry]?
        public struct PluginEntry: Codable {
            public let enabled: Bool
        }
    }
}
