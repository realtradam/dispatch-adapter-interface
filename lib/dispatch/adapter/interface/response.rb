# frozen_string_literal: true

module Dispatch
  module Adapter
    # stop_reason ∈
    #   :end_turn       — natural completion
    #   :max_tokens     — output truncated by max_tokens
    #   :tool_use       — assistant emitted tool calls
    #   :pause_turn     — provider asked us to resubmit (Anthropic)
    #   :refusal        — provider refused to answer
    #   :sensitive      — output blocked by safety filters
    #   :error          — adapter-level failure
    Response = Struct.new(:content, :tool_calls, :model, :stop_reason, :usage, keyword_init: true) do
      def initialize(model:, stop_reason:, usage:, content: nil, tool_calls: [])
        super
      end
    end

    UsageCost = Struct.new(
      :input, :output, :cache_read, :cache_write, :total,
      keyword_init: true
    ) do
      def initialize(input: 0.0, output: 0.0, cache_read: 0.0,
                     cache_write: 0.0, total: 0.0)
        super
      end
    end

    Usage = Struct.new(
      :input_tokens, :output_tokens,
      :cache_read_tokens, :cache_creation_tokens,
      :reasoning_tokens, :premium_requests, :cost,
      keyword_init: true
    ) do
      def initialize(input_tokens:, output_tokens:,
                     cache_read_tokens: 0, cache_creation_tokens: 0,
                     reasoning_tokens: 0, premium_requests: nil, cost: nil)
        super
      end
    end

    # Recognised :type values:
    #   :text_start, :text_delta, :text_end
    #   :thinking_start, :thinking_delta, :thinking_end
    #   :tool_use_start, :tool_use_delta, :tool_use_end
    StreamDelta = Struct.new(:type, :text, :tool_call_id, :tool_name, :argument_delta, keyword_init: true) do
      def initialize(type:, text: nil, tool_call_id: nil, tool_name: nil, argument_delta: nil)
        super
      end
    end
  end
end
