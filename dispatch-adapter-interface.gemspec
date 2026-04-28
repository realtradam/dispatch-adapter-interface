# frozen_string_literal: true

require_relative "lib/dispatch/adapter/interface/version"

Gem::Specification.new do |spec|
  spec.name = "dispatch-adapter-interface"
  spec.version = Dispatch::Adapter::Interface::VERSION
  spec.authors = ["Adam Malczewski"]
  spec.email = ["github@tradam.dev"]

  spec.summary = "Shared interface for Dispatch LLM adapter gems"
  spec.description = "Defines the base class, data structs, and error hierarchy shared by all " \
                     "Dispatch adapter gems (Copilot, Claude, Tester, etc.)."
  spec.homepage = "https://github.com/realtradam/dispatch-adapter-interface"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
