# frozen_string_literal: true

module Dispatch
  module Adapter
    # +cache_control+ values:
    #   nil                                — no cache breakpoint (default)
    #   { type: :ephemeral }               — provider default TTL
    #   { type: :ephemeral, ttl: :"5m" }   — short-lived cache
    #   { type: :ephemeral, ttl: :"1h" }   — long-lived cache
    ToolDefinition = Struct.new(
      :name, :description, :parameters, :cache_control,
      keyword_init: true
    ) do
      def initialize(name:, description:, parameters:, cache_control: nil)
        super
      end
    end
  end
end
