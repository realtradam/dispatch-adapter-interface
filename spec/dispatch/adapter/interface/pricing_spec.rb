# frozen_string_literal: true

RSpec.describe Dispatch::Adapter::Pricing do
  let(:pricing) do
    Dispatch::Adapter::ModelPricing.new(
      input_per_mtok: 3.0,
      output_per_mtok: 15.0,
      cache_read_per_mtok: 0.3,
      cache_write_per_mtok: 3.75
    )
  end

  let(:model_info) do
    Dispatch::Adapter::ModelInfo.new(
      id: "claude-3-5-sonnet-20241022",
      name: "Claude 3.5 Sonnet",
      max_context_tokens: 200_000,
      supports_vision: true,
      supports_tool_use: true,
      supports_streaming: true,
      pricing: pricing
    )
  end

  describe ".calculate" do
    it "returns nil if model_info is nil" do
      usage = Dispatch::Adapter::Usage.new(input_tokens: 100, output_tokens: 50)
      expect(described_class.calculate(usage, nil)).to be_nil
    end

    it "returns nil if model_info.pricing is nil" do
      info = Dispatch::Adapter::ModelInfo.new(
        id: "test", name: "test", max_context_tokens: 100,
        supports_vision: false, supports_tool_use: false, supports_streaming: false
      )
      usage = Dispatch::Adapter::Usage.new(input_tokens: 100, output_tokens: 50)
      expect(described_class.calculate(usage, info)).to be_nil
    end

    it "calculates cost correctly for fixed numbers" do
      # input: 1,000,000 tokens * $3.00 / 1M = $3.00
      # output: 2,000,000 tokens * $15.00 / 1M = $30.00
      # cache_read: 1,000,000 tokens * $0.30 / 1M = $0.30
      # cache_write: 1,000,000 tokens * $3.75 / 1M = $3.75
      # total: 3.00 + 30.00 + 0.30 + 3.75 = 37.05
      usage = Dispatch::Adapter::Usage.new(
        input_tokens: 1_000_000,
        output_tokens: 2_000_000,
        cache_read_tokens: 1_000_000,
        cache_creation_tokens: 1_000_000
      )

      cost = described_class.calculate(usage, model_info)

      expect(cost.input).to eq(3.0)
      expect(cost.output).to eq(30.0)
      expect(cost.cache_read).to eq(0.3)
      expect(cost.cache_write).to eq(3.75)
      expect(cost.total).to eq(37.05)
    end

    it "handles smaller token counts" do
      # input: 1,000 tokens * $3.00 / 1M = $0.003
      # output: 500 tokens * $15.00 / 1M = $0.0075
      # total: 0.0105
      usage = Dispatch::Adapter::Usage.new(
        input_tokens: 1_000,
        output_tokens: 500
      )

      cost = described_class.calculate(usage, model_info)

      expect(cost.input).to eq(0.003)
      expect(cost.output).to eq(0.0075)
      expect(cost.total).to eq(0.0105)
    end

    it "ignores reasoning_tokens (as they should be included in output_tokens by the adapter)" do
      usage = Dispatch::Adapter::Usage.new(
        input_tokens: 1_000,
        output_tokens: 500,
        reasoning_tokens: 200
      )

      cost = described_class.calculate(usage, model_info)
      # output cost should still be 500 * 15 / 1M = 0.0075
      expect(cost.output).to eq(0.0075)
    end
  end
end
