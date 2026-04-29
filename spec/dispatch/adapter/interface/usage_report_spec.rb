# frozen_string_literal: true

RSpec.describe "UsageReport and friends" do
  describe Dispatch::Adapter::UsageWindow do
    it "constructs with required keywords only" do
      w = described_class.new(id: "daily", label: "Daily")
      expect(w.id).to eq("daily")
      expect(w.label).to eq("Daily")
      expect(w.duration_ms).to be_nil
      expect(w.resets_at).to be_nil
    end

    it "accepts optional duration_ms and resets_at" do
      t = Time.now
      w = described_class.new(id: "hourly", label: "Hourly", duration_ms: 3_600_000, resets_at: t)
      expect(w.duration_ms).to eq(3_600_000)
      expect(w.resets_at).to eq(t)
    end

    it "round-trips through to_h" do
      w = described_class.new(id: "daily", label: "Daily", duration_ms: 86_400_000)
      h = w.to_h
      expect(h[:id]).to eq("daily")
      expect(h[:label]).to eq("Daily")
      expect(h[:duration_ms]).to eq(86_400_000)
      expect(h[:resets_at]).to be_nil
    end
  end

  describe Dispatch::Adapter::UsageAmount do
    it "constructs with required unit keyword only" do
      a = described_class.new(unit: :tokens)
      expect(a.unit).to eq(:tokens)
      expect(a.used).to be_nil
      expect(a.limit).to be_nil
      expect(a.remaining).to be_nil
      expect(a.used_fraction).to be_nil
      expect(a.remaining_fraction).to be_nil
    end

    it "accepts all optional fields" do
      a = described_class.new(
        unit: :requests,
        used: 250,
        limit: 1000,
        remaining: 750,
        used_fraction: 0.25,
        remaining_fraction: 0.75
      )
      expect(a.used).to eq(250)
      expect(a.limit).to eq(1000)
      expect(a.remaining).to eq(750)
      expect(a.used_fraction).to eq(0.25)
      expect(a.remaining_fraction).to eq(0.75)
    end

    it "round-trips through to_h" do
      a = described_class.new(unit: :usd, used: 1.5, limit: 10.0)
      h = a.to_h
      expect(h[:unit]).to eq(:usd)
      expect(h[:used]).to eq(1.5)
      expect(h[:limit]).to eq(10.0)
      expect(h[:remaining]).to be_nil
    end

    it "supports all documented unit symbols" do
      %i[percent tokens requests usd minutes bytes unknown].each do |u|
        expect { described_class.new(unit: u) }.not_to raise_error
      end
    end
  end

  describe Dispatch::Adapter::UsageLimitEntry do
    let(:amount) { Dispatch::Adapter::UsageAmount.new(unit: :tokens, used: 100, limit: 1000) }

    it "constructs with required keywords only" do
      entry = described_class.new(id: "token_limit", label: "Token Limit", scope: "org", amount: amount)
      expect(entry.id).to eq("token_limit")
      expect(entry.label).to eq("Token Limit")
      expect(entry.scope).to eq("org")
      expect(entry.amount).to eq(amount)
      expect(entry.window).to be_nil
      expect(entry.status).to eq(:unknown)
      expect(entry.notes).to eq([])
    end

    it "accepts optional window, status, and notes" do
      window = Dispatch::Adapter::UsageWindow.new(id: "daily", label: "Daily")
      entry = described_class.new(
        id: "req_limit",
        label: "Request Limit",
        scope: "user",
        amount: amount,
        window: window,
        status: :ok,
        notes: ["All good"]
      )
      expect(entry.window).to eq(window)
      expect(entry.status).to eq(:ok)
      expect(entry.notes).to eq(["All good"])
    end

    it "supports all documented status values" do
      %i[ok warning exhausted unknown].each do |s|
        entry = described_class.new(id: "x", label: "X", scope: "org", amount: amount, status: s)
        expect(entry.status).to eq(s)
      end
    end

    it "round-trips through to_h" do
      entry = described_class.new(id: "e1", label: "E1", scope: "workspace", amount: amount)
      h = entry.to_h
      expect(h[:id]).to eq("e1")
      expect(h[:label]).to eq("E1")
      expect(h[:scope]).to eq("workspace")
      expect(h[:status]).to eq(:unknown)
      expect(h[:notes]).to eq([])
    end
  end

  describe Dispatch::Adapter::UsageReport do
    let(:amount) { Dispatch::Adapter::UsageAmount.new(unit: :requests, used: 5, limit: 100) }
    let(:entry) do
      Dispatch::Adapter::UsageLimitEntry.new(
        id: "req", label: "Requests", scope: "account", amount: amount
      )
    end

    it "constructs with required keywords only" do
      report = described_class.new(provider: "acme", limits: [entry])
      expect(report.provider).to eq("acme")
      expect(report.limits).to eq([entry])
      expect(report.fetched_at).to be_a(Time)
      expect(report.metadata).to eq({})
      expect(report.raw).to be_nil
    end

    it "accepts all optional fields" do
      t = Time.now
      raw = { "foo" => "bar" }
      report = described_class.new(
        provider: "acme",
        limits: [entry],
        fetched_at: t,
        metadata: { source: "api" },
        raw: raw
      )
      expect(report.fetched_at).to eq(t)
      expect(report.metadata).to eq({ source: "api" })
      expect(report.raw).to eq(raw)
    end

    it "round-trips through to_h" do
      t = Time.now
      report = described_class.new(provider: "test_provider", limits: [], fetched_at: t)
      h = report.to_h
      expect(h[:provider]).to eq("test_provider")
      expect(h[:limits]).to eq([])
      expect(h[:fetched_at]).to eq(t)
      expect(h[:metadata]).to eq({})
      expect(h[:raw]).to be_nil
    end

    it "struct equality holds when values are the same" do
      t = Time.now
      a = described_class.new(provider: "p", limits: [], fetched_at: t)
      b = described_class.new(provider: "p", limits: [], fetched_at: t)
      expect(a).to eq(b)
    end
  end
end
