# frozen_string_literal: true

module Dispatch
  module Adapter
    ModelPricing = Struct.new(
      :input_per_mtok, :output_per_mtok,
      :cache_read_per_mtok, :cache_write_per_mtok,
      keyword_init: true
    ) do
      def initialize(input_per_mtok:, output_per_mtok:,
                     cache_read_per_mtok: 0.0, cache_write_per_mtok: 0.0)
        super
      end
    end

    ModelInfo = Struct.new(
      :id, :name, :max_context_tokens,
      :supports_vision, :supports_tool_use, :supports_streaming,
      :premium_request_multiplier,
      :pricing,
      keyword_init: true
    ) do
      def initialize(id:, name:, max_context_tokens:, supports_vision:, supports_tool_use:, supports_streaming:,
                     premium_request_multiplier: nil, pricing: nil)
        super
      end
    end
  end
end
