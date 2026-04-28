# frozen_string_literal: true

RSpec.describe Dispatch::Adapter::Interface do
  it "has a version number" do
    expect(Dispatch::Adapter::Interface::VERSION).not_to be_nil
  end

  it "exposes the Base class" do
    expect(Dispatch::Adapter::Base).to be_a(Class)
  end

  it "exposes error classes" do
    expect(Dispatch::Adapter::Error).to be < StandardError
    expect(Dispatch::Adapter::AuthenticationError).to be < Dispatch::Adapter::Error
    expect(Dispatch::Adapter::RateLimitError).to be < Dispatch::Adapter::Error
    expect(Dispatch::Adapter::ServerError).to be < Dispatch::Adapter::Error
    expect(Dispatch::Adapter::RequestError).to be < Dispatch::Adapter::Error
    expect(Dispatch::Adapter::ConnectionError).to be < Dispatch::Adapter::Error
  end

  it "exposes data structs" do
    expect(Dispatch::Adapter::Message).to be_a(Class)
    expect(Dispatch::Adapter::TextBlock).to be_a(Class)
    expect(Dispatch::Adapter::ImageBlock).to be_a(Class)
    expect(Dispatch::Adapter::ToolUseBlock).to be_a(Class)
    expect(Dispatch::Adapter::ToolResultBlock).to be_a(Class)
    expect(Dispatch::Adapter::ToolDefinition).to be_a(Class)
    expect(Dispatch::Adapter::Response).to be_a(Class)
    expect(Dispatch::Adapter::Usage).to be_a(Class)
    expect(Dispatch::Adapter::StreamDelta).to be_a(Class)
    expect(Dispatch::Adapter::ModelInfo).to be_a(Class)
  end
end
