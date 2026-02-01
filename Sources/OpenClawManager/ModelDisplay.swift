import Foundation

struct ModelDisplay {
    let id: String
    let displayName: String
    let provider: String
    let isLocal: Bool
    let isKnown: Bool
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

    static let knownAliases: [String: String] = [
        "anthropic/claude-opus-4-5": "Opus",
        "anthropic/claude-sonnet-4-5": "Sonnet",
        "google-gemini-cli/gemini-3-pro-preview": "Flash"
    ]

    static func getDisplayName(from modelId: String) -> String {
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

struct ModelAliases: Codable {
    static let knownAliases: [String: String] = [
        "anthropic/claude-opus-4-5": "Opus",
        "anthropic/claude-sonnet-4-5": "Sonnet",
        "google-gemini-cli/gemini-3-pro-preview": "Flash"
    ]
}
