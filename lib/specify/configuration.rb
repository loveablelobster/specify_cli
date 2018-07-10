# frozen_string_literal: true

require_relative 'configuration/config'
require_relative 'configuration/db_config'
require_relative 'configuration/host_config'

module Specify
  # A module that provides configuration facilities
  module Configuration
    DATABASES = File.expand_path(Pathname.new('~/.specify_dbs.rc.yaml'))
  end
end
