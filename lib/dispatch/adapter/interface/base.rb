# frozen_string_literal: true

module Dispatch
  module Adapter
    class Base
      # Send a chat request.
      #
      # @param _messages [Array<Message>] the conversation messages
      # @param system [String, Array<TextBlock, Hash>, nil] system prompt;
      #   a String or an array of TextBlock / Hash content blocks (for
      #   providers that support cached system prompts).
      # @param tools [Array<ToolDefinition, Hash>] tool definitions
      # @param stream [Boolean] whether to stream the response
      # @param max_tokens [Integer, nil] maximum tokens to generate
      # @param thinking [String, Hash, nil] extended thinking config;
      #   adapters do their own validation.
      #   - String: "low" | "medium" | "high"
      #   - Hash: e.g. { enabled: true, budget_tokens: 10_000 }
      # @param tool_choice [Symbol, Hash, nil] tool-selection policy:
      #   :auto | :any | :none | { type: :tool, name: "fn" }
      #   Adapters MAY ignore this.
      # @param cache_retention [Symbol, nil] caching hint:
      #   :none | :short | :long | nil
      #   Adapters MAY ignore this.
      # @param metadata [Hash, nil] arbitrary passthrough metadata (e.g. { user_id: "u1" }).
      #   Adapters MAY ignore this.
      # @param betas [Array<String>, String, nil] extra provider-beta entries.
      #   Adapters MAY ignore this.
      # @return [Response]
      def chat(
        _messages,
        system: nil,
        tools: [],
        stream: false,
        max_tokens: nil,
        thinking: nil,
        tool_choice: nil,     # rubocop:disable Lint/UnusedMethodArgument
        cache_retention: nil, # rubocop:disable Lint/UnusedMethodArgument
        metadata: nil,        # rubocop:disable Lint/UnusedMethodArgument
        betas: nil,           # rubocop:disable Lint/UnusedMethodArgument
        &_block
      )
        raise NotImplementedError, "#{self.class}#chat must be implemented"
      end

      def model_name
        raise NotImplementedError, "#{self.class}#model_name must be implemented"
      end

      def count_tokens(_messages, system: nil, tools: []) # rubocop:disable Lint/UnusedMethodArgument
        -1
      end

      def list_models
        raise NotImplementedError, "#{self.class}#list_models must be implemented"
      end

      def provider_name
        self.class.name
      end

      def max_context_tokens
        nil
      end

      # Subscription quota / utilisation. Return nil if the provider has no
      # such concept (raw API-key tier, etc.).
      # @return [Dispatch::Adapter::UsageReport, nil]
      def usage_report
        nil
      end

      # Idempotent — perform any interactive login required (device flow,
      # OAuth PKCE, etc). Safe to call before the first chat/usage_report.
      def authenticate!
        nil
      end

      # True iff cached credentials are present and presumed valid.
      def authenticated?
        true
      end

      # Drop cached credentials.
      def logout!
        nil
      end
    end
  end
end
