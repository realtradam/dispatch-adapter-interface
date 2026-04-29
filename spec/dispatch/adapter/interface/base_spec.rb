# frozen_string_literal: true

RSpec.describe Dispatch::Adapter::Base do
  subject(:base) { described_class.new }

  describe "#chat" do
    it "raises NotImplementedError" do
      expect { base.chat([]) }.to raise_error(NotImplementedError, /chat must be implemented/)
    end

    it "accepts system: as a String without raising" do
      expect { base.chat([], system: "You are helpful.") }.to raise_error(NotImplementedError)
    end

    it "accepts system: as an Array of TextBlock without raising" do
      blocks = [Dispatch::Adapter::TextBlock.new(text: "prompt")]
      expect { base.chat([], system: blocks) }.to raise_error(NotImplementedError)
    end

    it "accepts tool_choice: without raising" do
      expect { base.chat([], tool_choice: :auto) }.to raise_error(NotImplementedError)
      expect { base.chat([], tool_choice: { type: :tool, name: "fn" }) }.to raise_error(NotImplementedError)
    end

    it "accepts cache_retention: without raising" do
      expect { base.chat([], cache_retention: :long) }.to raise_error(NotImplementedError)
    end

    it "accepts metadata: without raising" do
      expect { base.chat([], metadata: { user_id: "u1" }) }.to raise_error(NotImplementedError)
    end

    it "accepts betas: as Array without raising" do
      expect { base.chat([], betas: ["interleaved-thinking-2025-05-14"]) }.to raise_error(NotImplementedError)
    end

    it "accepts betas: as String without raising" do
      expect { base.chat([], betas: "interleaved-thinking-2025-05-14") }.to raise_error(NotImplementedError)
    end

    it "accepts thinking: as String without raising" do
      expect { base.chat([], thinking: "high") }.to raise_error(NotImplementedError)
    end

    it "accepts thinking: as Hash without raising" do
      expect { base.chat([], thinking: { enabled: true, budget_tokens: 10_000 }) }.to raise_error(NotImplementedError)
    end
  end

  describe "#model_name" do
    it "raises NotImplementedError" do
      expect { base.model_name }.to raise_error(NotImplementedError, /model_name must be implemented/)
    end
  end

  describe "#count_tokens" do
    it "returns -1" do
      expect(base.count_tokens([])).to eq(-1)
    end
  end

  describe "#list_models" do
    it "raises NotImplementedError" do
      expect { base.list_models }.to raise_error(NotImplementedError, /list_models must be implemented/)
    end
  end

  describe "#provider_name" do
    it "returns the class name" do
      expect(base.provider_name).to eq("Dispatch::Adapter::Base")
    end
  end

  describe "#max_context_tokens" do
    it "returns nil" do
      expect(base.max_context_tokens).to be_nil
    end
  end

  describe "#usage_report" do
    it "returns nil" do
      expect(base.usage_report).to be_nil
    end
  end

  describe "#authenticate!" do
    it "returns nil" do
      expect(base.authenticate!).to be_nil
    end
  end

  describe "#authenticated?" do
    it "returns true" do
      expect(base.authenticated?).to be(true)
    end
  end

  describe "#logout!" do
    it "returns nil" do
      expect(base.logout!).to be_nil
    end
  end
end
