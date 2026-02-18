import Foundation

public struct ModelDisplay: Identifiable {
    public let id: String
    public let displayName: String
    public let provider: String
    public let isLocal: Bool
    public let isKnown: Bool
    
    public init(id: String, displayName: String, provider: String, isLocal: Bool, isKnown: Bool) {
        self.id = id
        self.displayName = displayName
        self.provider = provider
        self.isLocal = isLocal
        self.isKnown = isKnown
    }
}

public struct CloudModels: Codable {
    public static let knownProviders: [String: String] = [
        "anthropic": "Anthropic",
        "google-gemini-cli": "Google Gemini",
        "openai": "OpenAI",
        "openrouter": "OpenRouter",
        "groq": "Groq",
        "zai": "Z.ai"
    ]

    public static let knownAliases: [String: String] = [
        "anthropic/claude-opus-4-5": "Opus",
        "anthropic/claude-sonnet-4-5": "Sonnet",
        "google-gemini-cli/gemini-3-pro-preview": "Flash"
    ]

    public static func getDisplayName(from modelId: String) -> String {
        // Known model ID to display name mapping
        let modelMap: [String: String] = [
            "gemini-3-pro-preview": "Gemini 3.0 Pro",
            "gemini-3-flash": "Gemini 3.0 Flash",
            "claude-opus-4-5": "Claude Opus 4.5",
            "claude-sonnet-4-5": "Claude Sonnet 4.5",
            "claude-sonnet-4-7": "Claude Sonnet 4.7",
            "gpt-4o-mini": "GPT-4o Mini",
            "llama-3.3-70b-versatile": "Llama 3.3 70B",
            "qwen2.5-coder:14b": "Qwen 2.5 Coder 14B",
            "qwen2.5:7b": "Qwen 2.5 7B",
            "glm-4.7": "GLM-4.7"
        ]

        return modelMap[modelId.lowercased()] ?? modelId
    }
}

public struct ModelAliases: Codable {
    public static let knownAliases: [String: String] = [
        "anthropic/claude-opus-4-5": "Opus",
        "anthropic/claude-sonnet-4-5": "Sonnet",
        "google-gemini-cli/gemini-3-pro-preview": "Flash"
    ]
}
