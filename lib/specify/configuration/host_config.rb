# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class HostConfig < Config
      def initialize(file = nil)
        super(file)
      end

      def params
        super.fetch :dir_names
      end

      def resolve_host(dir)
        params.fetch dir
      end
    end
  end
end
