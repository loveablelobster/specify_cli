# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class Config
      attr_reader :params

      def initialize(file = nil)
        @params = Psych.load_file(file || DATABASES)
      end
    end
  end
end
