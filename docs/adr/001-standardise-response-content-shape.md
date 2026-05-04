# ADR 001 — Standardise `Response#content` shape across adapters

**Status:** OPEN — divergence found in production, no resolution committed yet.
**Date raised:** 2026-04-29
**Reporter:** integration in `dispatch-tui/build.rb`
**Affected gems:** `dispatch-adapter-copilot` (>= 0.5.0), `dispatch-adapter-claude` (>= 0.1.0)

---

## Context

The whole point of `dispatch-adapter-interface` is that downstream code can
hold an `adapter` of unknown concrete type and call `adapter.chat(...)` with
the same canonical structs, get back a canonical `Response`, and not have to
know whether the bytes came from GitHub Copilot, Anthropic, or anywhere else.
Adapters are meant to be **drop-in replacements** for each other through this
interface.

`Dispatch::Adapter::Response#content` is documented today only by the
`Response` Struct definition in
`lib/dispatch/adapter/interface/response.rb`:

```ruby
Response = Struct.new(:content, :tool_calls, :model, :stop_reason, :usage,
                      keyword_init: true)
```

The interface does **not** specify the shape of `content`.

## What actually ships

| Adapter | Shipped shape of `Response#content` |
|---|---|
| `Dispatch::Adapter::Copilot` (0.5.0) | `String` (the assistant's text) or `nil` |
| `Dispatch::Adapter::Claude` (0.1.0)  | `nil` **or** `Array<TextBlock \| ThinkingBlock \| RedactedThinkingBlock>` |

Both shapes are individually defensible:

- Copilot's wire protocol returns a single string per assistant turn, so a
  flat `String` is the obvious 1:1 mapping.
- Claude's wire protocol returns an array of typed content blocks (text,
  thinking, redacted_thinking), and *those blocks must be echoed back
  verbatim on the next turn* — `ThinkingBlock#signature` in particular is
  a cryptographic blob that Anthropic validates on the round-trip. So a
  flat string would be lossy.

But shipped together, **the two adapters are not interchangeable through
the interface**. Real-world breakage:

```ruby
# Code written against Copilot:
preview = response.content.lines.first(5).join.strip
#=> NoMethodError: undefined method `lines' for an instance of Array

blocks << Dispatch::Adapter::TextBlock.new(text: response.content) \
  if response.content && !response.content.empty?
#=> Wraps an Array of blocks inside a TextBlock#text=, losing structure
```

This was hit live in `dispatch-tui/build.rb` the first time `opus-4.6` was
selected, after months of working fine against Copilot. The downstream had
to add a provider-aware `response_content_text(content)` shim and a
case-on-class branch in `append_assistant!`. That is **exactly** the
abstraction-leak this gem is supposed to prevent.

## Proposed resolution (sketch — needs discussion)

Pick one of:

### Option A — Always an Array of blocks (recommended)

`Response#content` is **always** an `Array` of canonical content blocks
(empty array if the model said nothing). Single-string returns are wrapped
in a 1-element array `[TextBlock.new(text: "...")]`.

- Pro: lossless across all providers; future-proofs for image / thinking /
  redacted-thinking output without further breakage.
- Pro: matches Anthropic's wire shape, which is the strict superset.
- Pro: the `append_assistant!` round-trip becomes a trivial pass-through;
  no provider-aware code needed downstream.
- Con: every existing Copilot consumer that does
  `response.content.lines` / `response.content.start_with?("...")` /
  `response.content + foo` breaks. **This is a major version bump for
  `dispatch-adapter-interface` and both adapter gems.**
- Con: the most common 90% case (extracting plain text) goes from
  `r.content` to `r.content.filter_map { |b| b.text if b.is_a?(TextBlock) }.join`.
  Mitigate with `Response#text` convenience that flattens to a String.

### Option B — Always a String

`Response#content` is **always** a `String` (empty string if the model
said nothing). Block structure (thinking, signatures) moves into a new
`Response#content_blocks` Array that defaults to `[]` for adapters that
don't have one.

- Pro: zero-churn for current Copilot consumers.
- Con: `Claude#chat` then has two related fields it must populate
  consistently (the flattened text plus the structured blocks). Consumers
  who care about thinking signatures must remember to round-trip
  `content_blocks` instead of `content`. Subtle wrong-default footgun.
- Con: still requires a major version bump on
  `dispatch-adapter-claude` (its current `content: Array` callers break).

### Option C — Both

Add `Response#text` (always String) **and** `Response#blocks` (always
Array). Deprecate `#content` in 0.3, remove in 1.0.

- Pro: explicit migration path; both shapes available during transition.
- Con: docs / spec churn; adapters must populate both correctly.

## Required for any option

Whatever the chosen shape, `dispatch-adapter-interface` MUST:

1. Document the shape of `Response#content` (and any new fields) in
   `response.rb`'s comment block, with the same precision the existing
   `stop_reason` enum uses.
2. Document round-trip rules: which fields MUST be echoed verbatim on the
   next turn (today: ThinkingBlock#signature, RedactedThinkingBlock#data;
   probably more later).
3. Ship a shared spec / contract test (in `dispatch-adapter-tester` or
   similar) that every adapter passes, so this divergence cannot recur
   silently.

## Tracking

- Downstream workaround: see `dispatch-tui/build.rb`,
  `response_content_text` helper and the `case response.content` in
  `append_assistant!`. Both should be deleted once the interface is
  fixed.
- Reproducer: select `opus-4.6` in `bundle exec ruby
  dispatch-tui/build.rb`, run any plan; the very first assistant turn
  triggers the `NoMethodError` against pre-fix code.

## Owner

Unassigned. Any change here cascades through every adapter and every
downstream — should not be done casually. Discuss before implementing.
