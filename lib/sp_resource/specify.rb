# frozen_string_literal: true

require_relative 'specify/database'
require_relative 'specify/session'

module SPResource
  module Specify
    module LoginError
      INCONSISTENT_LOGIN = 'User is already logged in to a different collection'
    end
  end
end
