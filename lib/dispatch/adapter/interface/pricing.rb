# frozen_string_literal: true

module Dispatch
  module Adapter
    module Pricing
      module_function

      # Calculates UsageCost from a Usage and ModelInfo.
      #
      # NOTE: Reasoning tokens are NOT separately priced here.
      # Anthropic bills them as output tokens; OpenAI o-series likewise.
      # It is assumed that output_tokens includes reasoning_tokens if applicable.
      def calculate(usage, model_info)
        return nil unless model_info&.pricing

        p = model_info.pricing
        mtok = ->(tokens, rate) { (rate.to_f / 1_000_000.0) * tokens.to_i }

        input  = mtok.call(usage.input_tokens,           p.input_per_mtok)
        output = mtok.call(usage.output_tokens,          p.output_per_mtok)
        cread  = mtok.call(usage.cache_read_tokens,      p.cache_read_per_mtok)
        cwrite = mtok.call(usage.cache_creation_tokens,  p.cache_write_per_mtok)

        UsageCost.new(
          input: input,
          output: output,
          cache_read: cread,
          cache_write: cwrite,
          total: input + output + cread + cwrite
        )
      end
    end
  end
end
