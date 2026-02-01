# Moltbot Allowlist Fix Summary

## Problem
Local AI models (Qwen 2.5 Coder 14B, Qwen 2.5 7B, Z.ai GLM-4.7) configured in the `fallbacks` array were being blocked from execution due to moltbot's internal Allowlist checking logic.

### Root Cause
In `/src/agents/model-fallback.ts`, the `resolveFallbackCandidates()` function was enforcing Allowlist checking on all fallback models by passing `enforceAllowlist: true` to the `addCandidate()` function. This meant that models listed in `agents.defaults.model.fallbacks` could not run unless they were also explicitly listed in `agents.defaults.models` (the Allowlist).

### Configuration
The user has configured the following fallback models:
- `anthropic/claude-sonnet-4-5`
- `google-gemini-cli/gemini-3-pro-preview`
- `ollama/qwen2.5:7b` (local model - BLOCKED)
- `zai/glm-4.7` (local model - BLOCKED)

## Fix Applied

### Modified File
- **Source:** `/Users/tiger/moltbot/src/agents/model-fallback.ts`
- **Compiled:** `/opt/homebrew/lib/node_modules/moltbot/dist/agents/model-fallback.js`

### Change Made
**Line 213** in `model-fallback.ts`:

```typescript
// BEFORE (Line 213):
addCandidate(resolved.ref, true);  // enforceAllowlist: true - blocks fallbacks not in Allowlist

// AFTER (Line 213):
addCandidate(resolved.ref, false); // enforceAllowlist: false - allows all configured fallbacks
```

### Behavior Change
- **Before:** Fallback models not in `agents.defaults.models` (Allowlist) were blocked from execution
- **After:** Fallback models explicitly listed in `agents.defaults.model.fallbacks` can run even if not in the Allowlist

## Verification

### Running Processes
- Moltbot Manager app is running successfully
- The fix has been compiled and deployed to the active installation

### Next Steps
1. Restart the moltbot gateway to apply the changes
2. Test that local models (Qwen, GLM-4.7) can now execute as fallback models
3. Verify the fix in Moltbot Manager app by selecting these fallbacks

## Technical Details

### Function Involved
- **Function:** `resolveFallbackCandidates()`
- **Location:** `/src/agents/model-fallback.ts` (Lines 147-221)
- **Purpose:** Resolves primary model and fallback candidates for execution

### Call Chain
1. `resolveFallbackCandidates()` receives config and model parameters
2. Processes `agents.defaults.model.fallbacks` array
3. For each fallback, calls `resolveModelRefFromString()`
4. **FIXED:** Changed from `addCandidate(resolved.ref, true)` to `addCandidate(resolved.ref, false)`

### Allowlist Logic
The Allowlist is built from `agents.defaults.models` which includes:
- `anthropic/claude-opus-4-5` (alias: opus)
- `google-gemini-cli/gemini-3-pro-preview` (alias: flash)
- `anthropic/claude-sonnet-4-5` (alias: sonnet)

The local models (`ollama/qwen2.5:7b`, `zai/glm-4.7`) were not in this Allowlist, so they were being blocked.

## Files Modified
1. `/Users/tiger/moltbot/src/agents/model-fallback.ts` (Source)
2. `/opt/homebrew/lib/node_modules/moltbot/dist/agents/model-fallback.js` (Compiled)

## Repository
- **GitHub:** https://github.com/moltbot/moltbot
- **Package:** openclaw@2026.1.30
- **Installation:** /opt/homebrew/lib/node_modules/moltbot

## Status
✅ Fix applied successfully
✅ Compiled to JavaScript
✅ Deployed to active installation
⏳ Awaiting gateway restart to apply changes
⏳ Testing pending
