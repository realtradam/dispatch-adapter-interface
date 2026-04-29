# frozen_string_literal: true

module Dispatch
  module Adapter
    Message = Struct.new(:role, :content, keyword_init: true)

    # +cache_control+ values:
    #   nil                                — no cache breakpoint (default)
    #   { type: :ephemeral }               — provider default TTL
    #   { type: :ephemeral, ttl: :"5m" }   — short-lived cache
    #   { type: :ephemeral, ttl: :"1h" }   — long-lived cache
    TextBlock = Struct.new(:type, :text, :cache_control, keyword_init: true) do
      def initialize(text:, cache_control: nil, type: "text")
        super(type:, text:, cache_control:)
      end
    end

    ImageBlock = Struct.new(:type, :source, :media_type, keyword_init: true) do
      def initialize(source:, media_type:, type: "image")
        super(type:, source:, media_type:)
      end
    end

    ToolUseBlock = Struct.new(:type, :id, :name, :arguments, keyword_init: true) do
      def initialize(id:, name:, arguments:, type: "tool_use")
        super(type:, id:, name:, arguments:)
      end
    end

    ToolResultBlock = Struct.new(:type, :tool_use_id, :content, :is_error, keyword_init: true) do
      def initialize(tool_use_id:, content:, is_error: false, type: "tool_result")
        super(type:, tool_use_id:, content:, is_error:)
      end
    end

    ThinkingBlock = Struct.new(:type, :thinking, :signature, keyword_init: true) do
      def initialize(thinking:, signature: nil, type: "thinking")
        super(type:, thinking:, signature:)
      end
    end

    RedactedThinkingBlock = Struct.new(:type, :data, keyword_init: true) do
      def initialize(data:, type: "redacted_thinking")
        super(type:, data:)
      end
    end
  end
end
