# frozen_string_literal: true

require_relative 'configuration/config'
require_relative 'configuration/db_config'
require_relative 'configuration/host_config'

module Specify
  # A module that provides configuration facilities
  module Configuration
    CONFIG = File.expand_path(Pathname.new('~/.specify.rc'))
  end
end
