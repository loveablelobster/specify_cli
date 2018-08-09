# frozen_string_literal: true

module Specify
  module Configuration
    # A class that maps file directories to hosts
    class HostConfig < Config
      attr_reader :directory_map

      def initialize(file = nil)
        super(file)
        @saved = true
      end

      # -> +true+ or +false+
      # Returns +true+ if _directory_ is mapped.
      def directory?(directory)
        params.key? directory
      end

      # Maps _directory_ to _host_.
      def map_directory(directory, host)
        raise "Directory '#{directory}' already mapped" if params[directory]
        params[directory] = host
        touch
      end

      # -> Hash
      # Returns a Hash with the parameters for the current directory mappings
      # from the configuration YAML file.
      def params
        super.fetch :dir_names
      end

      # -> String
      # Returns the host name that is mapped to _directory_
      def resolve_host(directory)
        params.fetch directory
      end
    end
  end
end
