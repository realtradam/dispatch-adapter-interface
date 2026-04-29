# frozen_string_literal: true

module Dispatch
  module Adapter
    UsageWindow = Struct.new(:id, :label, :duration_ms, :resets_at, keyword_init: true) do
      def initialize(id:, label:, duration_ms: nil, resets_at: nil)
        super
      end
    end

    UsageAmount = Struct.new(
      :used, :limit, :remaining,
      :used_fraction, :remaining_fraction,
      :unit, keyword_init: true
    ) do
      # unit ∈ :percent | :tokens | :requests | :usd | :minutes | :bytes | :unknown
      def initialize(unit:, used: nil, limit: nil, remaining: nil,
                     used_fraction: nil, remaining_fraction: nil)
        super
      end
    end

    UsageLimitEntry = Struct.new(
      :id, :label, :scope, :window, :amount, :status, :notes,
      keyword_init: true
    ) do
      # status ∈ :ok | :warning | :exhausted | :unknown
      def initialize(id:, label:, scope:, amount:, window: nil,
                     status: :unknown, notes: [])
        super
      end
    end

    UsageReport = Struct.new(
      :provider, :fetched_at, :limits, :metadata, :raw,
      keyword_init: true
    ) do
      def initialize(provider:, limits:, fetched_at: Time.now, metadata: {}, raw: nil)
        super
      end
    end
  end
end
