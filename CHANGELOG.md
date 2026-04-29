# Changelog

All notable changes to this project will be documented in this file.

## 0.2.0 — 2025-01-01

### Added

- **`UsageWindow`** — struct for rolling-window quota definitions (id, label, duration_ms, resets_at).
- **`UsageAmount`** — struct for utilisation values with unit, used/limit/remaining, and fraction fields.
  Supported units: `:percent | :tokens | :requests | :usd | :minutes | :bytes | :unknown`.
- **`UsageLimitEntry`** — struct combining a scope, window, amount, and status for a single quota limit.
  Supported statuses: `:ok | :warning | :exhausted | :unknown`.
- **`UsageReport`** — top-level struct returned by `Base#usage_report`; carries provider, fetched_at,
  limits, metadata, and raw response.
- **`Base#usage_report`** — returns `nil` by default; subscription-aware adapters override this.
- **`Base#authenticate!`** — idempotent login lifecycle hook; returns `nil` by default.
- **`Base#authenticated?`** — returns `true` by default.
- **`Base#logout!`** — drops cached credentials; returns `nil` by default.
- **`ThinkingBlock`** — content block for Claude extended-thinking output; defaults `type` to
  `"thinking"`, carries `thinking:` text and optional `signature:`.
- **`RedactedThinkingBlock`** — redacted variant; defaults `type` to `"redacted_thinking"`, carries `data:`.
- **`StreamDelta` thinking events** — `:thinking_start`, `:thinking_delta`, `:thinking_end` added to the
  documented `:type` vocabulary; `:thinking_delta` reuses the existing `text:` field.
- **`TextBlock#cache_control`** — optional keyword (default `nil`) for prompt-cache breakpoints.
  Convention: `nil | { type: :ephemeral } | { type: :ephemeral, ttl: :"5m" } | { type: :ephemeral, ttl: :"1h" }`.
- **`ToolDefinition#cache_control`** — same cache-breakpoint keyword on tool definitions.
- **`Base#chat` extended kwargs** — added `tool_choice:`, `cache_retention:`, `metadata:`, `betas:`
  (all `nil` by default); `thinking:` now accepts a Hash in addition to String. All new kwargs are
  optional and adapters MAY ignore them.
- **Stop-reason vocabulary** — documented comment in `response.rb` listing the seven canonical
  `:stop_reason` values: `:end_turn`, `:max_tokens`, `:tool_use`, `:pause_turn`, `:refusal`,
  `:sensitive`, `:error`.
- **`RateLimiter`** — migrated `Dispatch::Adapter::RateLimiter` from `dispatch-adapter-copilot` into
  this gem so other adapters can depend on it independently. The Copilot gem re-exports the constant
  for backwards compatibility.

## 0.1.0 — Initial release

- `Base` class with `chat`, `model_name`, `count_tokens`, `list_models`, `provider_name`,
  `max_context_tokens`.
- `Message`, `TextBlock`, `ImageBlock`, `ToolUseBlock`, `ToolResultBlock`, `ToolDefinition`.
- `Response`, `Usage`, `UsageCost`, `StreamDelta`.
- `ModelInfo`, `ModelPricing`, `Pricing.calculate`.
- Error hierarchy: `Error`, `AuthenticationError`, `RateLimitError`, `ServerError`, `RequestError`,
  `ConnectionError`.
