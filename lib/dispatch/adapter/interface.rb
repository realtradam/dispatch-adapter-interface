# frozen_string_literal: true

require_relative "interface/version"

require_relative "interface/errors"
require_relative "interface/message"
require_relative "interface/response"
require_relative "interface/tool_definition"
require_relative "interface/model_info"
require_relative "interface/pricing"
require_relative "interface/usage_report"
require_relative "interface/rate_limiter"
require_relative "interface/base"

module Dispatch
  module Adapter
    module Interface
    end
  end
end
