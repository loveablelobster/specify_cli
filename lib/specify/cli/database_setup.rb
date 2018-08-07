# frozen_string_literal: true

module Specify
  module CLI
    def self.db_config?
      File.exist?(DATABASES)
    end
  end
end
