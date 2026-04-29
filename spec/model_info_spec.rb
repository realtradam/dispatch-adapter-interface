# frozen_string_literal: true

require "spec_helper"

RSpec.describe Dispatch::Adapter::ModelInfo do
  let(:base_kwargs) do
    {
      id: "gpt-4",
      name: "GPT-4",
      max_context_tokens: 8192,
      supports_vision: false,
      supports_tool_use: true,
      supports_streaming: true
    }
  end

  it "still works without pricing (existing shape unchanged)" do
    info = described_class.new(**base_kwargs)
    expect(info.id).to eq("gpt-4")
    expect(info.name).to eq("GPT-4")
    expect(info.max_context_tokens).to eq(8192)
    expect(info.supports_vision).to be(false)
    expect(info.supports_tool_use).to be(true)
    expect(info.supports_streaming).to be(true)
    expect(info.premium_request_multiplier).to be_nil
    expect(info.pricing).to be_nil
  end

  it "accepts a ModelPricing and exposes it on #pricing" do
    pricing = Dispatch::Adapter::ModelPricing.new(input_per_mtok: 3.0, output_per_mtok: 15.0)
    info = described_class.new(**base_kwargs, pricing: pricing)
    expect(info.pricing).to be_a(Dispatch::Adapter::ModelPricing)
    expect(info.pricing.input_per_mtok).to eq(3.0)
    expect(info.pricing.output_per_mtok).to eq(15.0)
  end
end

RSpec.describe Dispatch::Adapter::ModelPricing do
  it "requires input_per_mtok and output_per_mtok" do
    pricing = described_class.new(input_per_mtok: 3.0, output_per_mtok: 15.0)
    expect(pricing.input_per_mtok).to eq(3.0)
    expect(pricing.output_per_mtok).to eq(15.0)
  end

  it "defaults cache_read_per_mtok and cache_write_per_mtok to 0.0" do
    pricing = described_class.new(input_per_mtok: 1.0, output_per_mtok: 2.0)
    expect(pricing.cache_read_per_mtok).to eq(0.0)
    expect(pricing.cache_write_per_mtok).to eq(0.0)
  end

  it "accepts explicit cache pricing" do
    pricing = described_class.new(
      input_per_mtok: 3.0,
      output_per_mtok: 15.0,
      cache_read_per_mtok: 0.3,
      cache_write_per_mtok: 3.75
    )
    expect(pricing.cache_read_per_mtok).to eq(0.3)
    expect(pricing.cache_write_per_mtok).to eq(3.75)
  end
end
